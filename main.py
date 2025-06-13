import json
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
import google.generativeai as genai

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"               # Replace with your Gemini API key
COLLECTION_NAME = "text_vectors"
TOP_K = 3

# === Load Sentence Transformer Model ===
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🚀 Using device: {device}")
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

# === Connect to Qdrant ===
qdrant = QdrantClient(
    url="https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333", 
    api_key="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A",
)

# === Configure Gemini ===
genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

# === Step 1: Get user input ===
user_query = input("🧠 Enter your question: ")
query_vector = model.encode(user_query, device=device).tolist()

# === Step 2: Search Qdrant ===
print("🔎 Searching Qdrant for relevant context...")
results = qdrant.search(
    collection_name=COLLECTION_NAME,
    query_vector=query_vector,
    limit=TOP_K
)
print(results)
# === Step 3: Format retrieved context ===
if not results:
    print("❌ No matching results found.")
    exit()

retrieved_context = "\n".join([
    f"- {hit.payload.get('text')}" for hit in results
])

# === Step 4: Construct prompt for Gemini ===
prompt = f"""
You are an intelligent and empathetic assistant. Use the following context to answer the user's question.

📚 Context:
{retrieved_context}

🧑 User asked: "{user_query}"

🎯 Your job: Respond helpfully, conversationally, and clearly.
"""

# === Step 5: Generate response with Gemini ===
print("\n🧠 Generating response from Gemini...\n")
response = gemini_model.generate_content(prompt)
print("🤖 Gemini Response:\n")
print(response.text)
