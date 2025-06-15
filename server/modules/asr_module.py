# app.py
import os
import base64
import queue
import threading
from voicebot_SHILEDAR_submission.server import Flask, request
from flask_cors import CORS
from flask_socketio import SocketIO
from google.cloud import speech
from google.cloud import translate_v2 as translate

# ✅ Set your service account credentials
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "C:\\Users\\Ram\\Desktop\\voxgenie\\neon-airway-452008-u7-858f21505cb2.json"

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# ✅ Initialize Google clients
speech_client = speech.SpeechClient()
translate_client = translate.Client()

# ✅ Global stores for audio queues and client languages
audio_queues = {}
client_lang = {}

def audio_generator(q):
    while True:
        chunk = q.get()
        if chunk is None:
            break
        yield speech.StreamingRecognizeRequest(audio_content=chunk)

# ✅ Transliteration function to Devanagari
def transliterate_to_devnagari(text, target_lang="hi"):
    try:
        print(f"📤 Translating: {text} -> {target_lang}")
        result = translate_client.translate(
            text,
            target_language=target_lang,
            source_language="en",  # Speech returns Romanized Hindi/Marathi
            format_='text'
        )
        print(f"📥 Translated: {result['translatedText']}")
        return result['translatedText']
    except Exception as e:
        print("❌ Transliteration error:", e)
        return text

# ✅ Transcription processing
def start_transcription(sid):
    q = audio_queues[sid]
    print(f"🔤 Transcription thread started for {sid}")

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="hi-IN",  # Use English always for speech recognition
        enable_automatic_punctuation=True,
    )
    streaming_config = speech.StreamingRecognitionConfig(
        config=config,
        interim_results=True,
        single_utterance=False
    )

    try:
        responses = speech_client.streaming_recognize(
            config=streaming_config,
            requests=audio_generator(q)
        )

        for response in responses:
            if not response.results:
                continue

            result = response.results[0]
            if result.is_final or result.alternatives:
                transcript = result.alternatives[0].transcript.strip()

                # ⛏️ Dynamically get language for current SID
                lang_code = client_lang.get(sid, "en-IN")
                
                # 🎯 Translate only if Hindi or Marathi
                if lang_code in ["hi-IN", "mr-IN"]:
                    target_lang = "hi" if lang_code == "hi-IN" else "mr"
                    transcript = transliterate_to_devnagari(transcript, target_lang)

                print(f"📝 [{sid}]: {transcript}")
                socketio.emit("transcription", {"text": transcript}, to=sid)

    except Exception as e:
        print(f"❌ Error for {sid}:", str(e))


# ✅ WebSocket handlers
@socketio.on("connect")
def handle_connect(auth=None):
    sid = request.sid
    print(f"✅ Client connected: {sid}")
    audio_queues[sid] = queue.Queue()
    client_lang[sid] = "en-IN"  # default language
    threading.Thread(target=start_transcription, args=(sid,), daemon=True).start()

@socketio.on("set_language")
def handle_set_language(lang):
    sid = request.sid
    print(f"🌐 Language set by {sid}: {lang}")
    if lang in ["hi-IN", "mr-IN", "en-IN"]:
        client_lang[sid] = lang
    print(transliterate_to_devnagari("hello bhai kaise ho", "hi"))


@socketio.on("audio_chunk")
def handle_audio_chunk(data):
    sid = request.sid
    if sid not in audio_queues:
        return
    try:
        chunk = base64.b64decode(data)
        audio_queues[sid].put(chunk)
    except Exception as e:
        print("❌ Error decoding chunk:", e)

@socketio.on("disconnect")
def handle_disconnect():
    sid = request.sid
    print(f"❌ Client disconnected: {sid}")
    if sid in audio_queues:
        audio_queues[sid].put(None)
        del audio_queues[sid]
    if sid in client_lang:
        del client_lang[sid]

# ✅ Basic health check endpoint
@app.route("/")
def home():
    return "🎤 Real-time Google STT Server Running"

if __name__ == "__main__":
    socketio.run(app, port=5000)
