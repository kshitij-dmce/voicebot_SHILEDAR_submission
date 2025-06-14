import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import PayloadSchemaType
from qdrant_client.models import ScoredPoint
from transformers import pipeline
import google.generativeai as genai

# === Constants ===
GEMINI_API_KEY = "YOUR_GEMINI_API_KEY"
QRDANT_API_KEY = "YOUR_QDRANT_API_KEY"
QRDANT_URL = "YOUR_QDRANT_URL"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

# === Setup ===
device = "cuda" if torch.cuda.is_available() else "cpu"
embedding_model = SentenceTransformer("all-MiniLM-L6-v2").to(device)
sentiment_model = pipeline("sentiment-analysis")

qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

genai.configure(api_key=GEMINI_API_KEY)
gemini = genai.GenerativeModel("gemini-1.5-flash")

# === Utility Functions ===

def analyze_sentiment(text: str) -> tuple[str, str]:
    result = sentiment_model(text)[0]
    label = result['label'].lower()

    tone_map = {
        "positive": "Respond with enthusiasm and confidence.",
        "neutral": "Respond with professionalism and clarity.",
        "negative": "Respond with empathy and reassurance to comfort the user."
    }
    return label, tone_map.get(label, "Respond with a helpful and respectful tone.")


def split_query_into_subparts(query: str) -> list[str]:
    split_prompt = f"""
Break the following user query into individual, clear questions:

"{query}"

Return each question on a new line with a bullet point or dash.
"""
    response = gemini.generate_content(split_prompt)
    lines = response.text.strip().split("\n")
    sub_queries = [line.strip("-• ").strip() for line in lines if line.strip()]
    return sub_queries


def weighted_score(hit: ScoredPoint) -> float:
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score


def search_qdrant(sub_query: str) -> list[dict]:
    try:
        vector = embedding_model.encode(sub_query, device=device).tolist()
        results = qdrant.search(collection_name=COLLECTION_NAME, query_vector=vector, limit=10)
        filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
        ranked = sorted(filtered, key=weighted_score, reverse=True)
        top_hits = ranked[:TOP_K]

        return [
            {
                "question": hit.payload.get("text"),
                "answer": hit.payload.get("answer"),
                "confidence": hit.payload.get("confidence"),
                "id": hit.id
            }
            for hit in top_hits
        ]
    except Exception as e:
        print(f"❌ Qdrant error: {e}")
        return []


def build_final_prompt(user_query: str, sentiment: str, instruction: str, retrieved_chunks: list[dict]) -> str:
    formatted_chunks = "\n\n".join(
        [f"Q: {chunk['question']}\nA: {chunk['answer']}" for chunk in retrieved_chunks]
    )

    final_prompt = f"""
You are a professional, friendly, and helpful human assistant.
User sentiment: {sentiment.upper()}
{instruction}
You're speaking to a customer who asked a complex question with multiple parts or simple question.

Here is all the background knowledge you need:

📚 Context:
{formatted_chunks}

🧑 The customer's original question: "{user_query}"

🎯 Your task: Give one fluent, human-like response that combines all the information naturally. 
Avoid repeating context. Respond clearly, conversationally, and accurately.
"""
    return final_prompt


def generate_gemini_response(prompt: str) -> str:
    try:
        response = gemini.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        print(f"Gemini generation error: {e}")
        return "Sorry, I encountered an error while generating the response."


# === Optional: Ensure Payload Index Exists (for setup)
def create_payload_index():
    try:
        qdrant.create_payload_index(
            collection_name=COLLECTION_NAME,
            field_name="domain",
            field_schema=PayloadSchemaType.KEYWORD
        )
        print("✅ 'domain' payload index ensured.")
    except Exception as e:
        print(f"⚠️ Payload index creation failed (maybe already exists): {e}")
