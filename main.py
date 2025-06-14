import json
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import Filter, FieldCondition, MatchValue
import google.generativeai as genai
from domain_classifier.semantic_model import SemanticDomainClassifier

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

# === Load Sentence Transformer Model ===
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🚀 Using device: {device}")
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

# === Connect to Qdrant ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === Load Semantic Domain Classifier ===
classifier = SemanticDomainClassifier()

# === Configure Gemini ===
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Get user input ===
user_query = input("🧠 Enter your (possibly complex) question: ")

# === Step 1: Break into sub-queries using Gemini ===
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

# === Step 2: Qdrant Search with Domain Filtering ===
retrieved_chunks = []
payload_output = []

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score

for sub_query in sub_queries:
    print(f"\n🔎 Searching for: {sub_query}")

    # Predict top domains
    top_domains = classifier.predict_top_k(sub_query, k=3)
    domain_labels = [label for label, score in top_domains if score >= 0.5]
    print(f"   ↪️ Domains: {domain_labels}")

    vec = model.encode(sub_query, device=device).tolist()

    # If no domain passed threshold, do unfiltered search
    if not domain_labels:
        print("⚠️ No high-confidence domain match. Running unfiltered search.")
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=vec,
            limit=10
        )
    else:
        filter_conditions = [
            FieldCondition(
                key="domain",
                match=MatchValue(value=domain)
            ) for domain in domain_labels
        ]
        query_filter = Filter(should=filter_conditions)  # Use `should` for OR condition
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=vec,
            query_filter=query_filter,
            limit=10
        )

    # Filter low confidence results
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

# === Step 3: Gemini Final Response ===
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

print("\n🧠 Generating Gemini response...\n")
response = gemini.generate_content(final_prompt)

print("🤖 Gemini Response:\n")
print(response.text)
