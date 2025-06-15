import json
import torch
from sentence_transformers import SentenceTransformer, util
from qdrant_client import QdrantClient
from qdrant_client.http.models import Filter, FieldCondition, MatchValue, PayloadSchemaType
from transformers import pipeline
import google.generativeai as genai
import nltk
import re
from functools import lru_cache

# === CONFIGURATION ===
GEMINI_API_KEY = "YOUR_GEMINI_API_KEY"
QRDANT_API_KEY = "YOUR_QDRANT_API_KEY"
QRDANT_URL = "YOUR_QDRANT_URL"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

# === SETUP ===
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🚀 Using device: {device}")

# === Load models once ===
embed_model = SentenceTransformer("all-MiniLM-L6-v2").to(device)
sentiment_model = pipeline("sentiment-analysis")
classifier = SentenceTransformer("sentence-transformers/distiluse-base-multilingual-cased-v2")

# === Qdrant Setup ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Load domain samples once ===
with open("domain_samples_cleaned.json", "r", encoding="utf-8") as f:
    domain_samples = json.load(f)

domain_vectors = {
    label: classifier.encode(samples, convert_to_tensor=True)
    for label, samples in domain_samples.items()
}

@lru_cache(maxsize=128)
def encode_query(text: str):
    return embed_model.encode(text, device=device).tolist()

def predict_top_domains(query, k=3):
    query_vec = classifier.encode(query, convert_to_tensor=True)
    scored = [(label, util.cos_sim(query_vec, vecs).mean().item()) for label, vecs in domain_vectors.items()]
    return [label for label, _ in sorted(scored, key=lambda x: x[1], reverse=True)[:k]]

def split_sentences(text):
    return re.split(r'(?<=[.?!])\s+', text.strip())

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    return 0.7 * confidence + 0.3 * (hit.score or 0)

# === MAIN LOGIC ===
user_query = input("💬 Enter your question: ").strip()
if not user_query:
    print("❌ Empty query.")
    exit()

# Sentiment
sentiment = sentiment_model(user_query)[0]['label'].lower()
tone_instruction = {
    "positive": "Respond with enthusiasm and confidence.",
    "neutral": "Respond with professionalism and clarity.",
    "negative": "Respond with empathy and reassurance to comfort the user."
}.get(sentiment, "Respond with a helpful and respectful tone.")

# Sub-queries
sub_queries = split_sentences(user_query)

# Domains
top_domains = predict_top_domains(user_query)
print(f"📂 Top domains: {top_domains}")

# Search Qdrant
retrieved_chunks = []
for sub_query in sub_queries:
    print(f"🔍 Searching: {sub_query}")
    vec = encode_query(sub_query)
    try:
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=vec,
            limit=TOP_K * 2,
            query_filter=Filter(must=[
                FieldCondition(key="domain", match=MatchValue(value=domain))
                for domain in top_domains
            ])
        )
        filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
        top_hits = sorted(filtered, key=weighted_score, reverse=True)[:TOP_K]
        for hit in top_hits:
            retrieved_chunks.append(f"Q: {hit.payload.get('text')}\nA: {hit.payload.get('answer')}")
    except Exception as e:
        print(f"❌ Qdrant error: {e}")

context = "\n\n".join(retrieved_chunks) if retrieved_chunks else "No specific information found."

# Final Prompt
final_prompt = f"""
You are a **real human sales representative from Lenden Club**, a trusted name in peer-to-peer lending and personal finance solutions in India.

Your job is to help users understand Lenden Club’s services, guide them toward the right solution, and respond like a helpful, confident, and friendly sales expert.

Here is the customer’s message:
"{user_query}"

Detected Sentiment: {sentiment.upper()}
Recommended tone: {tone_instruction}

🧠 What you already know (from internal knowledge base):
{context}

Now craft a helpful, natural-sounding human response based on these rules:

- 🗣️ Speak casually but professionally — like you’re chatting with a real customer.
- ✅ Promote Lenden Club by highlighting its offerings (like loans, P2P investing, customer support, etc.) — but only if relevant to their question.
- 🔍 Never mention you are AI, virtual, or generated.
- ❌ Don’t guess, add links, or say “click here” unless explicitly present in the context.
- 🙋 If you’re unsure about something, politely acknowledge it and offer to connect them with support or suggest visiting the official website.
- 🔚 End with an inviting tone — encourage further questions or interest in Lenden Club’s services.

Write just the response — a fluent, warm, and confident reply like a professional sales rep would say on a call or in chat.
"""

print("\n🧠 Generating Gemini response...\n")
response = gemini.generate_content(final_prompt)

print("🤖 Gemini Response:\n")
print(response.text)
