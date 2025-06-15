import pandas as pd
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import PayloadSchemaType
import google.generativeai as genai
import time
from tqdm import tqdm
import re

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

INPUT_CSV = "test.csv"
OUTPUT_CSV = "SHILEDAR_submissions.csv"
QUESTION_COLUMN = "Questions"

# === Setup Devices and Models ===
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🖥️ Using device: {device}")
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

# === Connect to Qdrant ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === Configure Gemini ===
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Load CSV ===
df = pd.read_csv(INPUT_CSV)
responses = []

# === Helpers ===
def split_sentences(text):
    # Better sentence splitter for code-mixed questions
    parts = re.split(r'(?<=[.?!])\s+(?=[A-Z0-9अ-ह])|(?<=\?)\s+(?=\w)', text.strip())
    return [p.strip() for p in parts if p.strip()]

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score

# === Main Loop ===
for idx, row in tqdm(df.iterrows(), total=len(df), desc="Processing questions"):
    user_query = str(row.get(QUESTION_COLUMN, "")).strip()
    if not user_query:
        responses.append("Error: Empty question.")
        continue

    sub_queries = split_sentences(user_query)
    retrieved_chunks = []

    for sub_query in sub_queries:
        try:
            vec = model.encode(sub_query, device=device).tolist()
            results = qdrant.search(collection_name=COLLECTION_NAME, query_vector=vec, limit=10)
            filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
            top_hits = sorted(filtered, key=weighted_score, reverse=True)[:TOP_K]

            for hit in top_hits:
                q = hit.payload.get("text")
                a = hit.payload.get("answer")
                if q and a:
                    retrieved_chunks.append(f"Q: {q}\nA: {a}")
        except Exception as e:
            print(f"❌ Qdrant error at row {idx}: {e}")

    retrieved_context = "\n\n".join(retrieved_chunks) or "No context found for the query."

    final_prompt = f"""
You are a helpful and professional human assistant working for Lenden Club.

The customer asked the following question:
"{user_query}"

Here is the background knowledge from our internal database:
{retrieved_context}

Your task:
- Write a friendly and fluent answer.
- Be clear, accurate, and avoid repeating context.
- Don’t mention you're an AI or assistant.
- If unsure, suggest reaching out to support or visiting the website.

Respond conversationally as a real human would.
"""

    try:
        response = gemini.generate_content(final_prompt)
        answer = response.text.strip()
    except Exception as e:
        print(f"⚠️ Gemini error at row {idx}: {e}")
        answer = "Error generating response."

    responses.append(answer)
    time.sleep(0.5)  # to avoid Gemini rate limiting

# === Save to CSV ===
df["Responses"] = responses
df.to_csv(OUTPUT_CSV, index=False)
print(f"\n✅ Done! Saved responses to: {OUTPUT_CSV}")
