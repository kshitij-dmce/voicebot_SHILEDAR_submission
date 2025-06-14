# import json
# import torch
# from sentence_transformers import SentenceTransformer
# from qdrant_client import QdrantClient
# from qdrant_client.http.models import (
#     Filter, FieldCondition, MatchValue, PayloadSchemaType
# )
# import google.generativeai as genai
# from transformers import pipeline

# # === CONFIGURATION ===
# GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
# QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
# QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
# COLLECTION_NAME = "Lenden_ faqs"
# TOP_K = 3
# MIN_CONFIDENCE = 0.6

# # === Load Sentence Transformer Model ===
# device = "cuda" if torch.cuda.is_available() else "cpu"
# print(f"🚀 Using device: {device}")
# model = SentenceTransformer("all-MiniLM-L6-v2").to(device)
# sentiment_model = pipeline("sentiment-analysis")

# # === Connect to Qdrant ===
# qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# # === Ensure payload index exists for 'domain' (optional, now unused) ===
# try:
#     qdrant.create_payload_index(
#         collection_name=COLLECTION_NAME,
#         field_name="domain",
#         field_schema=PayloadSchemaType.KEYWORD
#     )
#     print("✅ 'domain' index created or already exists.")
# except Exception as e:
#     print(f"⚠️ Could not create index (maybe it already exists): {e}")

# # === Configure Gemini ===
# genai.configure(api_key=GEMINI_API_KEY)
# gemini = genai.GenerativeModel("gemini-1.5-flash")

# # === Get user input ===
# user_query = input("🧠 Enter your (possibly complex) question: ")

# # Analyze sentiment of the user's query
# sentiment_result = sentiment_model(user_query)[0]  # {'label': 'NEGATIVE', 'score': 0.95}
# tone_label = sentiment_result['label'].lower()

# # Map sentiment to tone style
# tone_instruction = {
#     "positive": "Respond with enthusiasm and confidence.",
#     "neutral": "Respond with professionalism and clarity.",
#     "negative": "Respond with empathy and reassurance to comfort the user."
# }.get(tone_label, "Respond with a helpful and respectful tone.")


# # === Step 1: Break into sub-queries using Gemini ===
# split_prompt = f"""
# Break the following user query into individual, clear questions:

# "{user_query}"

# Return each question on a new line with a bullet point or dash.
# """
# split_response = gemini.generate_content(split_prompt)
# split_text = split_response.text.strip()
# sub_queries = [line.strip("-• ") for line in split_text.split("\n") if line.strip()]

# print("\n📌 Sub-queries extracted:")
# for q in sub_queries:
#     print(f"→ {q}")

# # === Step 2: Qdrant Search (no domain filtering) ===
# retrieved_chunks = []
# payload_output = []

# def weighted_score(hit):
#     confidence = hit.payload.get("confidence", 0)
#     qdrant_score = hit.score or 0
#     return 0.7 * confidence + 0.3 * qdrant_score

# for sub_query in sub_queries:
#     print(f"\n🔎 Searching for: {sub_query}")

#     vec = model.encode(sub_query, device=device).tolist()

#     try:
#         results = qdrant.search(collection_name=COLLECTION_NAME, query_vector=vec, limit=10)
#     except Exception as e:
#         print(f"❌ Error querying Qdrant: {e}")
#         continue

#     # Filter and rank results
#     filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
#     ranked = sorted(filtered, key=weighted_score, reverse=True)
#     top_hits = ranked[:TOP_K]

#     for hit in top_hits:
#         q = hit.payload.get("text")
#         a = hit.payload.get("answer")
#         retrieved_chunks.append(f"Q: {q}\nA: {a}")
#         payload_output.append({
#             "id": hit.id,
#             "payload": hit.payload
#         })

# # === Step 3: Gemini Final Response ===
# retrieved_context = "\n\n".join(retrieved_chunks)

# final_prompt = f"""
# You are a professional, friendly, and helpful human assistant.
# User sentiment: {tone_label.upper()}
# {tone_instruction}
# You're speaking to a customer who asked a complex question with multiple parts or simple question.

# Here is all the background knowledge you need:

# 📚 Context:
# {retrieved_context}

# 🧑 The customer's original question: "{user_query}"

# 🎯 Your task: Give one fluent, human-like response that combines all the information naturally. 
# Avoid repeating context. Respond clearly, conversationally, and accurately.
# """

# print("\n🧠 Generating Gemini response...\n")
# response = gemini.generate_content(final_prompt)

# print("🤖 Gemini Response:\n")
# print(response.text)

import json
import torch
import requests
from sentence_transformers import SentenceTransformer, util
from qdrant_client import QdrantClient
from qdrant_client.http.models import (
    Filter, FieldCondition, MatchValue, PayloadSchemaType
)
from transformers import pipeline
import google.generativeai as genai

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

# === DOMAIN CLASSIFIER ===
class SemanticDomainClassifier:
    def __init__(self, sample_file="domain_samples_cleaned.json"):
        self.model = SentenceTransformer("sentence-transformers/distiluse-base-multilingual-cased-v2")

        with open(sample_file, "r", encoding="utf-8") as f:
            self.domains = json.load(f)

        self.domain_vectors = self._encode_samples()

    def _encode_samples(self):
        vectors = {}
        for label, examples in self.domains.items():
            vectors[label] = self.model.encode(examples, convert_to_tensor=True)
        return vectors

    def predict_top_k(self, query, k=3):
        query_vec = self.model.encode(query, convert_to_tensor=True)
        scores = []
        for label, vectors in self.domain_vectors.items():
            score = util.cos_sim(query_vec, vectors).mean().item()
            scores.append((label, score))
        scores.sort(key=lambda x: x[1], reverse=True)
        return [label for label, _ in scores[:k]]

# === Init Models ===
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🚀 Using device: {device}")
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)
classifier = SemanticDomainClassifier()
sentiment_model = pipeline("sentiment-analysis")

# === Connect to Qdrant ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === Create domain index (optional) ===
try:
    qdrant.create_payload_index(
        collection_name=COLLECTION_NAME,
        field_name="domain",
        field_schema=PayloadSchemaType.KEYWORD
    )
    print("✅ 'domain' index created or already exists.")
except Exception as e:
    print(f"⚠️ Could not create index (maybe it already exists): {e}")

# === Configure Gemini ===
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Get user input ===
user_query = input("🧠 Enter your (possibly complex) question: ")

sentiment_result = sentiment_model(user_query)[0]  # {'label': 'NEGATIVE', 'score': 0.95}
tone_label = sentiment_result['label'].lower()

# Map sentiment to tone style
tone_instruction = {
    "positive": "Respond with enthusiasm and confidence.",
    "neutral": "Respond with professionalism and clarity.",
    "negative": "Respond with empathy and reassurance to comfort the user."
}.get(tone_label, "Respond with a helpful and respectful tone.")


# === Step 1: Classify domains ===
top_domains = classifier.predict_top_k(user_query, k=3)
print(f"📂 Top predicted domains: {top_domains}")

# === Step 2: Break into sub-queries using Gemini ===
split_prompt = f"""
Break the following user query into individual, clear questions:

"{user_query}"

Return each question on a new line with a bullet point or dash.
"""
split_response = gemini.generate_content(split_prompt)
split_text = split_response.text.strip()
sub_queries = [line.strip("-• ") for line in split_text.split("\n") if line.strip()]

print("\n📌 Sub-queries extracted:")
for q in sub_queries:
    print(f"→ {q}")

# === Step 3: Qdrant Search (restricted to top 3 domains) ===
retrieved_chunks = []
payload_output = []

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score

for sub_query in sub_queries:
    print(f"\n🔎 Searching for: {sub_query}")

    vec = model.encode(sub_query, device=device).tolist()

    try:
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=vec,
            limit=20,
            query_filter=Filter(
                must=[
                    FieldCondition(key="domain", match=MatchValue(value=domain))
                    for domain in top_domains
                ]
            )
        )
    except Exception as e:
        print(f"❌ Error querying Qdrant: {e}")
        continue

    # Filter and rank results
    filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
    ranked = sorted(filtered, key=weighted_score, reverse=True)
    top_hits = ranked[:TOP_K]

    for hit in top_hits:
        q = hit.payload.get("text")
        a = hit.payload.get("answer")
        retrieved_chunks.append(f"Q: {q}\nA: {a}")
        payload_output.append({
            "id": hit.id,
            "payload": hit.payload
        })

# === Step 4: Gemini Final Response ===
retrieved_context = "\n\n".join(retrieved_chunks)

final_prompt = f"""
You are a professional, friendly, and helpful human assistant.
User sentiment: {tone_label.upper()}
{tone_instruction}
You're speaking to a customer who asked a complex question with multiple parts or simple question.

Here is all the background knowledge you need:

📚 Context:
{retrieved_context}

🧑 The customer's original question: "{user_query}"

🎯 Your task: Give one fluent, human-like response that combines all the information naturally. 
Avoid repeating context. Respond clearly, conversationally, and accurately.
"""


print("\n🧠 Generating Gemini response...\n")
response = gemini.generate_content(final_prompt)

print("🤖 Gemini Response:\n")
print(response.text)