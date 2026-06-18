import torch
from transformers import pipeline
import urllib.request
import numpy as np
import io
import soundfile as sf
import uvicorn
import threading
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

app = FastAPI(title="STT and TTS API")

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Loading models on device: {device}")

# 1. Initialize TTS Pipeline
tts_pipeline = pipeline("text-to-speech", model="microsoft/speecht5_tts", device=device)
url = "https://huggingface.co/datasets/Xenova/cmu-arctic-xvectors-extracted/resolve/main/cmu_us_slt_arctic-wav-arctic_a0001.bin"
with urllib.request.urlopen(url) as response:
    embedding_data = np.frombuffer(response.read(), dtype=np.float32)
speaker_embedding = torch.tensor(embedding_data).unsqueeze(0).to(device)

# 2. Initialize STT Pipeline (With ignore_warning=True)
stt_pipeline = pipeline(
    "automatic-speech-recognition", 
    model="openai/whisper-tiny", 
    device=device,
    chunk_length_s=30,
    ignore_warning=True  # Suppresses the experimental seq2seq chunking warning
)

class TextPayload(BaseModel):
    text: str

# --- Endpoint 1: Text-to-Speech ---
@app.post("/tts")
async def text_to_speech(payload: TextPayload):
    speech = tts_pipeline(payload.text, forward_params={"speaker_embeddings": speaker_embedding})
    buffer = io.BytesIO()
    sf.write(buffer, speech["audio"], speech["sampling_rate"], format="WAV")
    buffer.seek(0)
    return StreamingResponse(buffer, media_type="audio/wav")

# --- Endpoint 2: Speech-to-Text ---
@app.post("/stt")
async def speech_to_text(file: UploadFile = File(...)):
    audio_bytes = await file.read()
    audio_data, sampling_rate = sf.read(io.BytesIO(audio_bytes))
    stt_result = stt_pipeline({"raw": audio_data, "sampling_rate": sampling_rate})
    return {"text": stt_result["text"]}

# --- THE FIX: Run Uvicorn in a Background Thread ---
def run_server():
    config = uvicorn.Config(app, host="0.0.0.0", port=8000, log_level="info")
    server = uvicorn.Server(config)
    server.run()

if __name__ == "__main__":
    # Target the run_server function to execute in the background
    thread = threading.Thread(target=run_server, daemon=True)
    thread.start()
    print("🚀 FastAPI Server is running in the background on http://127.0.0.1:8000")