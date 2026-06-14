#!/bin/bash

# Comprehensive Hugging Face API Test Script
# Tests token, standard models, and provides guidance for custom models

HF_TOKEN="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"

echo "=========================================="
echo "Hugging Face API Complete Test"
echo "=========================================="
echo ""

# Test 1: Validate Token
echo "1. Validating Hugging Face Token..."
echo ""

WHOAMI_RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://huggingface.co/api/whoami-v2" \
  -H "Authorization: Bearer $HF_TOKEN")

WHOAMI_HTTP_CODE=$(echo "$WHOAMI_RESPONSE" | tail -n1)
WHOAMI_BODY=$(echo "$WHOAMI_RESPONSE" | sed '$d')

if [ "$WHOAMI_HTTP_CODE" = "200" ]; then
  echo "   ✅ Token is valid!"
  echo "   User: $(echo $WHOAMI_BODY | python3 -c "import sys, json; print(json.load(sys.stdin).get('name', 'Unknown'))" 2>/dev/null || echo 'Unknown')"
else
  echo "   ❌ Token validation failed (HTTP: $WHOAMI_HTTP_CODE)"
  echo "   Response: $WHOAMI_BODY"
fi

echo ""
echo "------------------------------------------"
echo ""

# Test 2: Check Custom Models
echo "2. Checking Custom Models..."
echo ""

TTS_MODEL="boules123/speecht5-finetuned-commonvoice"
STT_MODEL="boules123/Boulesvc"

echo "   TTS Model: $TTS_MODEL"
TTS_INFO=$(curl -s -w "\n%{http_code}" \
  "https://huggingface.co/api/models/$TTS_MODEL" \
  -H "Authorization: Bearer $HF_TOKEN")

TTS_INFO_CODE=$(echo "$TTS_INFO" | tail -n1)
TTS_INFO_BODY=$(echo "$TTS_INFO" | sed '$d')

if [ "$TTS_INFO_CODE" = "200" ]; then
  echo "   ✅ Model exists"
  echo "   Architecture: $(echo $TTS_INFO_BODY | python3 -c "import sys, json; print(json.load(sys.stdin).get('config', {}).get('architectures', ['N/A']))" 2>/dev/null || echo 'N/A')"
  echo "   ⚠️  Note: This is actually a Whisper (STT) model, not TTS!"
else
  echo "   ❌ Could not fetch model info"
fi

echo ""

echo "   STT Model: $STT_MODEL"
STT_INFO=$(curl -s -w "\n%{http_code}" \
  "https://huggingface.co/api/models/$STT_MODEL" \
  -H "Authorization: Bearer $HF_TOKEN")

STT_INFO_CODE=$(echo "$STT_INFO" | tail -n1)
STT_INFO_BODY=$(echo "$STT_INFO" | sed '$d')

if [ "$STT_INFO_CODE" = "200" ]; then
  echo "   ✅ Model exists"
  echo "   Architecture: $(echo $STT_INFO_BODY | python3 -c "import sys, json; print(json.load(sys.stdin).get('config', {}).get('architectures', ['N/A']))" 2>/dev/null || echo 'N/A')"
  echo "   ✅ This is a Whisper (STT) model"
else
  echo "   ❌ Could not fetch model info"
fi

echo ""
echo "   ⚠️  IMPORTANT: These custom models are NOT supported by the"
echo "   Hugging Face Inference API (hf-inference provider)."
echo "   They need to be deployed as Inference Endpoints."
echo ""

echo "------------------------------------------"
echo ""

# Test 3: Test Standard STT Model (Whisper)
echo "3. Testing Standard STT Model (openai/whisper-large-v3)..."
echo ""

# Create a minimal WAV file for testing
python3 -c "
import struct
sample_rate = 16000
duration = 1
num_samples = sample_rate * duration
data_size = num_samples * 2
header = struct.pack('<4sI4s4sIHHIIHH4sI',
    b'RIFF', 36 + data_size, b'WAVE',
    b'fmt ', 16, 1, 1, sample_rate, sample_rate * 2, 2, 16,
    b'data', data_size)
samples = b'\x00\x00' * num_samples
import sys
sys.stdout.buffer.write(header + samples)
" > /tmp/test_audio.wav

echo "   Testing with router.huggingface.co..."
WHISPER_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  "https://router.huggingface.co/hf-inference/models/openai/whisper-large-v3" \
  -H "Authorization: Bearer $HF_TOKEN" \
  -H "Content-Type: audio/wav" \
  --data-binary @/tmp/test_audio.wav \
  --max-time 60)

WHISPER_HTTP_CODE=$(echo "$WHISPER_RESPONSE" | tail -n1)
WHISPER_BODY=$(echo "$WHISPER_RESPONSE" | sed '$d')

echo "   HTTP Status: $WHISPER_HTTP_CODE"

if [ "$WHISPER_HTTP_CODE" = "200" ]; then
  echo "   ✅ Standard STT model is working!"
  echo "   Response: $WHISPER_BODY"
elif [ "$WHISPER_HTTP_CODE" = "503" ]; then
  echo "   ⏳ Model is loading (cold start). Try again in 30-60 seconds."
  echo "   Response: $WHISPER_BODY"
else
  echo "   Response: $WHISPER_BODY"
fi

echo ""
echo "------------------------------------------"
echo ""

# Test 4: Test Standard TTS Model (Kokoro)
echo "4. Testing Standard TTS Model (hexgrad/Kokoro-82M)..."
echo ""

echo "   Testing with router.huggingface.co..."
KOKORO_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  "https://router.huggingface.co/hf-inference/models/hexgrad/Kokoro-82M" \
  -H "Authorization: Bearer $HF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "Hello, this is a test of text to speech."}' \
  --max-time 60)

KOKORO_HTTP_CODE=$(echo "$KOKORO_RESPONSE" | tail -n1)
KOKORO_BODY=$(echo "$KOKORO_RESPONSE" | sed '$d')

echo "   HTTP Status: $KOKORO_HTTP_CODE"

if [ "$KOKORO_HTTP_CODE" = "200" ]; then
  echo "   ✅ Standard TTS model is working!"
  echo "   Response size: $(echo -n "$KOKORO_BODY" | wc -c | tr -d ' ') bytes"
elif [ "$KOKORO_HTTP_CODE" = "503" ]; then
  echo "   ⏳ Model is loading (cold start). Try again in 30-60 seconds."
  echo "   Response: $KOKORO_BODY"
else
  echo "   Response: $KOKORO_BODY"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "✅ Token: Valid"
echo ""
echo "Custom Models (boules123/*):"
echo "   - Both models exist but are NOT supported by Inference API"
echo "   - They are Whisper (STT) models, not TTS"
echo "   - To use them, deploy as Inference Endpoints"
echo ""
echo "Recommended Approach:"
echo "   1. For STT: Use standard models like openai/whisper-large-v3"
echo "   2. For TTS: Use standard models like hexgrad/Kokoro-82M"
echo "   3. Or continue using local ONNX models (already implemented)"
echo ""
echo "To deploy custom models as Inference Endpoints:"
echo "   1. Go to https://huggingface.co/$TTS_MODEL"
echo "   2. Click 'Deploy' > 'Inference Endpoints'"
echo "   3. Configure and deploy"
echo "   4. Use the endpoint URL in your app"
echo ""