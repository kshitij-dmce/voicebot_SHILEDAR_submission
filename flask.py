from flask import Flask, request, jsonify
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import PayloadSchemaType
import google.generativeai as genai
from transformers import pipeline
import json

# === Configuration ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

app = Flask(__name__)

# === Init Models ===
device = "cuda" if torch.cuda.is_available() else "cpu"
model = SentenceTransformer("all-MiniLM-L6-v2").to(device)
sentiment_model = pipeline("sentiment-analysis")
genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Qdrant Client ===
qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === Route ===
@app.route("/generate-response", methods=["POST"])
def generate_response():
    data = request.get_json()
    user_query = data.get("query", "")

    if not user_query.strip():
        return jsonify({"error": "Query is empty"}), 400

    # 1. Sentiment Analysis
    sentiment_result = sentiment_model(user_query)[0]
    tone_label = sentiment_result['label'].lower()
    tone_instruction = {
        "positive": "Respond with enthusiasm and confidence.",
        "neutral": "Respond with professionalism and clarity.",
        "negative": "Respond with empathy and reassurance to comfort the user."
    }.get(tone_label, "Respond with a helpful and respectful tone.")

    # 2. Break into Sub-queries using Gemini
    split_prompt = f"""
Break the following user query into individual, clear questions:

"{user_query}"

Return each question on a new line with a bullet point or dash.
"""
    split_response = gemini.generate_content(split_prompt)
    split_text = split_response.text.strip()
    sub_queries = [line.strip("-• ") for line in split_text.split("\n") if line.strip()]

    retrieved_chunks = []

    def weighted_score(hit):
        confidence = hit.payload.get("confidence", 0)
        qdrant_score = hit.score or 0
        return 0.7 * confidence + 0.3 * qdrant_score

    # 3. Search Qdrant
    for sub_query in sub_queries:
        try:
            vec = model.encode(sub_query, device=device).tolist()
            results = qdrant.search(collection_name=COLLECTION_NAME, query_vector=vec, limit=10)
            filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
            ranked = sorted(filtered, key=weighted_score, reverse=True)
            top_hits = ranked[:TOP_K]

            for hit in top_hits:
                q = hit.payload.get("text")
                a = hit.payload.get("answer")
                retrieved_chunks.append(f"Q: {q}\nA: {a}")
        except Exception as e:
            print(f"Qdrant error: {e}")

    # 4. Prepare Prompt for Final Response
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
    try:
        response = gemini.generate_content(final_prompt)
        return jsonify({
            "response": response.text,
            "sub_queries": sub_queries,
            "sentiment": tone_label,
            "raw_chunks": retrieved_chunks
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# === Main Run ===
if __name__ == "__main__":
    app.run(port=5000,host="0.0.0.0",debug=True)
