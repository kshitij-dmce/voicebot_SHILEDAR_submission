import pandas as pd
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import PayloadSchemaType
import google.generativeai as genai
import time

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

INPUT_CSV = "test_questions.csv"
OUTPUT_CSV = "inference_output.csv"
QUESTION_COLUMN = "question"

# === Setup Devices and Models ===
device = "cuda" if torch.cuda.is_available() else "cpu"
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

# === Connect to Qdrant ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === Configure Gemini ===
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Load CSV ===
df = pd.read_csv(INPUT_CSV)
responses = []

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score

# === Process Each Question ===
for idx, row in df.iterrows():
    user_query = row[QUESTION_COLUMN]

    # 1. Sub-query extraction using Gemini
    split_prompt = f"""
Break the following user query into individual, clear questions:

"{user_query}"

Return each question on a new line with a bullet point or dash.
"""
    try:
        split_response = gemini.generate_content(split_prompt)
        split_text = split_response.text.strip()
        sub_queries = [line.strip("-• ") for line in split_text.split("\n") if line.strip()]
    except Exception as e:
        print(f"❌ Failed to split query at row {idx}: {e}")
        responses.append("Error: failed to split query.")
        continue

    retrieved_chunks = []

    # 2. Qdrant search for each sub-query
    for sub_query in sub_queries:
        vec = model.encode(sub_query, device=device).tolist()
        try:
            results = qdrant.search(collection_name=COLLECTION_NAME, query_vector=vec, limit=10)
        except Exception as e:
            print(f"❌ Qdrant error for sub-query: {sub_query} | {e}")
            continue

        filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
        ranked = sorted(filtered, key=weighted_score, reverse=True)
        top_hits = ranked[:TOP_K]

        for hit in top_hits:
            q = hit.payload.get("text")
            a = hit.payload.get("answer")
            retrieved_chunks.append(f"Q: {q}\nA: {a}")

    # 3. Final Gemini Response
    retrieved_context = "\n\n".join(retrieved_chunks)
    final_prompt = f"""
You are a professional, friendly, and helpful human assistant.

You're speaking to a customer who asked a complex question with multiple parts.

Here is all the background knowledge you need:

📚 Context:
{retrieved_context}

🧑 The customer's original question: "{user_query}"

🎯 Your task: Give one fluent, human-like response that combines all the information naturally. 
Avoid repeating context. Respond clearly, conversationally, and accurately.
"""

    try:
        response = gemini.generate_content(final_prompt)
        answer = response.text.strip()
    except Exception as e:
        print(f"⚠️ Gemini generation failed at row {idx}: {e}")
        answer = "Error generating response"

    print(f"\n✅ Row {idx+1} processed.")
    responses.append(answer)
    time.sleep(0.5)  # prevent rate-limiting

# === Save responses ===
df["response"] = responses
df.to_csv(OUTPUT_CSV, index=False)
print(f"\n🎉 Done! Responses saved to {OUTPUT_CSV}")
