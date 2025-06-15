
# # from flask import Flask, request, jsonify
# # from flask_socketio import SocketIO, emit
# # import torch
# # from sentence_transformers import SentenceTransformer
# # from qdrant_client import QdrantClient
# # from qdrant_client.http.models import Filter, FieldCondition, MatchValue
# # import google.generativeai as genai
# # from transformers import AutoTokenizer, AutoModelForSequenceClassification
# # from concurrent.futures import ThreadPoolExecutor
# # from functools import lru_cache
# # from nltk.tokenize import sent_tokenize
# # import traceback
# # import torch.nn.functional as F
# # import nltk
# # import re

# # # Automatically download 'punkt' tokenizer if not already present

# # required_nltk_resources = ['punkt']

# # for resource in required_nltk_resources:
# #     try:
# #         nltk.data.find(f'tokenizers/{resource}')
# #     except LookupError:
# #         nltk.download(resource)


# # # === Configuration ===
# # GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
# # QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
# # QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
# # COLLECTION_NAME = "Lenden_ faqs"
# # TOP_K = 3
# # MIN_CONFIDENCE = 0.6

# # # === App Initialization ===
# # app = Flask(__name__)
# # socketio = SocketIO(app, cors_allowed_origins="*")

# # # === Load Models ===
# # device = "cuda" if torch.cuda.is_available() else "cpu"
# # embed_model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

# # tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased-finetuned-sst-2-english")
# # sentiment_model = AutoModelForSequenceClassification.from_pretrained("distilbert-base-uncased-finetuned-sst-2-english").to(device)

# # genai.configure(api_key=GEMINI_API_KEY)
# # gemini = genai.GenerativeModel("gemini-1.5-flash")
# # qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# # # === Utility: Sentence Splitter ===
# # def split_into_sentences(text):
# #     sentences = re.split(r'(?<=[.?!])\s+', text)
# #     return [s.strip() for s in sentences if s.strip()]

# # # === Caching Embeddings ===
# # @lru_cache(maxsize=128)
# # def get_query_vector(query: str):
# #     return embed_model.encode(query, device=device).tolist()

# # def weighted_score(hit):
# #     confidence = hit.payload.get("confidence", 0)
# #     qdrant_score = hit.score or 0
# #     return 0.7 * confidence + 0.3 * qdrant_score

# # # === Sentiment Detection ===
# # def detect_sentiment(text):
# #     inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(device)
# #     with torch.no_grad():
# #         outputs = sentiment_model(**inputs)
# #     probs = F.softmax(outputs.logits, dim=-1)
# #     label = "positive" if torch.argmax(probs) == 1 else "negative"
# #     return label

# # # === Qdrant Search Worker ===
# # def process_sub_query(sub_query):
# #     try:
# #         query_vector = get_query_vector(sub_query)
# #         results = qdrant.search(
# #             collection_name=COLLECTION_NAME,
# #             query_vector=query_vector,
# #             limit=TOP_K
# #         )
# #         filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
# #         ranked = sorted(filtered, key=weighted_score, reverse=True)
# #         return [f"Q: {hit.payload.get('text', '')}\nA: {hit.payload.get('answer', '')}" for hit in ranked]
# #     except Exception as e:
# #         print(f"[ERROR] Sub-query processing failed: {e}")
# #         return []

# # # === WebSocket Events ===
# # @socketio.on("connect")
# # def handle_connect():
# #     print("🟢 Client connected")

# # @socketio.on("disconnect")
# # def handle_disconnect():
# #     print("🔴 Client disconnected")

# # @socketio.on("user_query")
# # def handle_user_query(data):
# #     user_query = data.get("query", "").strip()
# #     if not user_query:
# #         emit("bot_response", {"error": "Query is empty"})
# #         return

# #     try:
# #         sentiment = detect_sentiment(user_query)
# #         tone_instruction = {
# #             "positive": "Respond with enthusiasm and confidence.",
# #             "neutral": "Respond with professionalism and clarity.",
# #             "negative": "Respond with empathy and reassurance to comfort the user."
# #         }.get(sentiment, "Respond with a helpful and respectful tone.")

# #         # Sub-queries via regex
# #         sub_queries = split_into_sentences(user_query)
# #         if not sub_queries:
# #             sub_queries = [user_query]

# #         # Parallel Qdrant search
# #         with ThreadPoolExecutor() as executor:
# #             results = list(executor.map(process_sub_query, sub_queries))
# #         retrieved_chunks = [item for sublist in results for item in sublist]

# #         if not retrieved_chunks:
# #             context = "No specific information found for this query."
# #         else:
# #             context = "\n\n".join(retrieved_chunks)

# #         # Final Gemini Response
# #         final_prompt = f"""
# # You are a **real human sales representative from Lenden Club**, a trusted name in peer-to-peer lending and personal finance solutions in India.

# # Your job is to help users understand Lenden Club’s services, guide them toward the right solution, and respond like a helpful, confident, and friendly sales expert.

# # Here is the customer’s message:
# # "{user_query}"

# # Detected Sentiment: {sentiment.upper()}
# # Recommended tone: {tone_instruction}

# # 🧠 What you already know (from internal knowledge base):
# # {context}

# # Now craft a helpful, natural-sounding human response based on these rules:

# # - 🗣️ Speak casually but professionally — like you’re chatting with a real customer.
# # - ✅ Promote Lenden Club by highlighting its offerings (like loans, P2P investing, customer support, etc.) — but only if relevant to their question.
# # - 🔍 Never mention you are AI, virtual, or generated.
# # - ❌ Don’t guess, add links, or say “click here” unless explicitly present in the context.
# # - 🙋 If you’re unsure about something, politely acknowledge it and offer to connect them with support or suggest visiting the official website.
# # - 🔚 End with an inviting tone — encourage further questions or interest in Lenden Club’s services.

# # Write just the response — a fluent, warm, and confident reply like a professional sales rep would say on a call or in chat.
# # """



# #         response = gemini.generate_content(final_prompt)
# #         emit("bot_response", {
# #             "response": response.text,
# #             "sub_queries": sub_queries,
# #             "sentiment": sentiment,
# #         })

# #     except Exception as e:
# #         print(f"[ERROR] {e}")
# #         traceback.print_exc()
# #         emit("bot_response", {
# #             "error": "Sorry, I encountered an error while processing your request.",
# #             "details": str(e)
# #         })

# # # === Run Server ===
# # if __name__ == "__main__":
# #     print("🚀 Clean server running on port 7000 (no NLTK)")
# #     socketio.run(app, host="0.0.0.0", port=7000, debug=False)


from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import Filter, FieldCondition, MatchValue
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from nltk.tokenize import sent_tokenize
import traceback
import torch.nn.functional as F
import nltk
import re
import boto3
import json

# === Ensure NLTK Tokenizer ===
nltk.download('punkt')

# === Configuration ===
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 3
MIN_CONFIDENCE = 0.6

AWS_ACCESS_KEY = "AKIA6KMFBVIXALBSD2FZ"
AWS_SECRET_KEY = "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"
AWS_REGION = "us-west-2"
BEDROCK_MODEL_ID = "anthropic.claude-3-5-sonnet-20240620-v1:0"

# === App Initialization ===
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# === Load Models ===
device = "cuda" if torch.cuda.is_available() else "cpu"
embed_model = SentenceTransformer("all-MiniLM-L6-v2").to(device)

tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased-finetuned-sst-2-english")
sentiment_model = AutoModelForSequenceClassification.from_pretrained("distilbert-base-uncased-finetuned-sst-2-english").to(device)

qdrant = QdrantClient(url=QRDANT_URL, api_key=QRDANT_API_KEY)

# === AWS Bedrock Setup ===
bedrock = boto3.client(
    service_name="bedrock-runtime",
    region_name=AWS_REGION,
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY
)

def generate_bedrock_response(prompt):
    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 1024,
        "temperature": 0.7,
        "top_k": 250,
        "top_p": 0.9
    }

    response = bedrock.invoke_model(
        modelId=BEDROCK_MODEL_ID,
        contentType="application/json",
        accept="application/json",
        body=json.dumps(body)
    )

    result = json.loads(response["body"].read())
    return result["content"][0]["text"]


# === Utilities ===
@lru_cache(maxsize=128)
def get_query_vector(query: str):
    return embed_model.encode(query, device=device).tolist()

def weighted_score(hit):
    confidence = hit.payload.get("confidence", 0)
    qdrant_score = hit.score or 0
    return 0.7 * confidence + 0.3 * qdrant_score

def detect_sentiment(text):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(device)
    with torch.no_grad():
        outputs = sentiment_model(**inputs)
    probs = F.softmax(outputs.logits, dim=-1)
    label = "positive" if torch.argmax(probs) == 1 else "negative"
    return label

def split_into_sentences(text):
    sentences = re.split(r'(?<=[.?!])\s+', text)
    return [s.strip() for s in sentences if s.strip()]

def process_sub_query(sub_query):
    try:
        query_vector = get_query_vector(sub_query)
        results = qdrant.search(
            collection_name=COLLECTION_NAME,
            query_vector=query_vector,
            limit=TOP_K
        )
        filtered = [r for r in results if r.payload.get("confidence", 0) >= MIN_CONFIDENCE]
        ranked = sorted(filtered, key=weighted_score, reverse=True)
        return [f"Q: {hit.payload.get('text', '')}\nA: {hit.payload.get('answer', '')}" for hit in ranked]
    except Exception as e:
        print(f"[ERROR] Sub-query processing failed: {e}")
        return []

# === WebSocket Events ===
@socketio.on("connect")
def handle_connect():
    print("🟢 Client connected")

@socketio.on("disconnect")
def handle_disconnect():
    print("🔴 Client disconnected")

@socketio.on("user_query")
def handle_user_query(data):
    user_query = data.get("query", "").strip()
    if not user_query:
        emit("bot_response", {"error": "Query is empty"})
        return

    try:
        sentiment = detect_sentiment(user_query)
        tone_instruction = {
            "positive": "Respond with enthusiasm and confidence.",
            "neutral": "Respond with professionalism and clarity.",
            "negative": "Respond with empathy and reassurance to comfort the user."
        }.get(sentiment, "Respond with a helpful and respectful tone.")

        sub_queries = split_into_sentences(user_query) or [user_query]

        with ThreadPoolExecutor() as executor:
            results = list(executor.map(process_sub_query, sub_queries))
        retrieved_chunks = [item for sublist in results for item in sublist]

        context = "No specific information found." if not retrieved_chunks else "\n\n".join(retrieved_chunks)
        fallback_instruction = "If the user's query is unrelated to financial help (e.g., greetings, weather, personal chat), politely steer the conversation toward how our platform can help them with loans, investments, or support services."
        sales_domains = {"onboarding", "p2p_lending", "sales_presales"}
        sales_boost = any(domain in sales_domains for domain in top_domains)
        sales_instruction = "Be highly persuasive, like a senior sales advisor. Highlight benefits clearly and make the offer sound trustworthy and compelling." if sales_boost else ""

        final_prompt = f"""
You are a real human sales representative from Lenden Club, a trusted name in peer-to-peer lending and personal finance solutions in India.

User message:
"{user_query}"

Sentiment: {sentiment.upper()}
Tone guide: {tone_instruction}

Internal knowledge:
{context}

Now reply like a friendly, helpful, real sales rep. Don't mention AI, don't guess, and end with a warm invitation to ask more.
"""

        response_text = generate_bedrock_response(final_prompt)

        emit("bot_response", {
            "response": response_text,
            "sub_queries": sub_queries,
            "sentiment": sentiment
        })

    except Exception as e:
        print(f"[ERROR] {e}")
        traceback.print_exc()
        emit("bot_response", {
            "error": "An error occurred while processing your request.",
            "details": str(e)
        })

# === Run Server ===
if __name__ == "__main__":
    print("🚀 Server running with AWS Bedrock on port 7000")
    socketio.run(app, host="0.0.0.0", port=7000, debug=True)
