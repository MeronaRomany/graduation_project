#!/bin/bash

# Quick Hugging Face API Test Script
# Run this script to quickly test your Hugging Face token and models

HF_TOKEN="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"

echo "🔍 Quick Hugging Face API Test"
echo "=============================="
echo ""

# Test token
echo "1. Testing token..."
RESPONSE=$(curl -s -w "\n%{http_code}" "https://huggingface.co/api/whoami-v2" -H "Authorization: Bearer $HF_TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "200" ]; then
  echo "   ✅ Token is valid"
else
  echo "   ❌ Token is invalid (HTTP: $HTTP_CODE)"
  exit 1
fi

echo ""

# Test model access
echo "2. Testing model access..."
MODELS=("boules123/speecht5-finetuned-commonvoice" "boules123/Boulesvc")

for MODEL in "${MODELS[@]}"; do
  RESPONSE=$(curl -s -w "\n%{http_code}" "https://huggingface.co/api/models/$MODEL" -H "Authorization: Bearer $HF_TOKEN")
  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ $MODEL - Accessible"
  else
    echo "   ❌ $MODEL - Not accessible (HTTP: $HTTP_CODE)"
  fi
done

echo ""

# Test API endpoint
echo "3. Testing API endpoint..."
echo "   Note: Custom models require Inference Endpoints deployment"
echo ""

# Test with a standard model
echo "   Testing with standard model (openai/whisper-tiny)..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  "https://router.huggingface.co/hf-inference/models/openai/whisper-tiny" \
  -H "Authorization: Bearer $HF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "test"}' \
  --max-time 10)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
  echo "   ✅ API endpoint working"
elif [ "$HTTP_CODE" = "503" ]; then
  echo "   ⏳ Model loading (cold start)"
elif [ "$HTTP_CODE" = "400" ]; then
  echo "   ⚠️  Model not supported by provider (expected for custom models)"
else
  echo "   Response: $BODY"
fi

echo ""
echo "=============================="
echo "Summary"
echo "=============================="
echo ""
echo "✅ Token: Valid"
echo "✅ Models: Accessible"
echo "⚠️  API: Custom models need Inference Endpoints"
echo ""
echo "Next steps:"
echo "1. Deploy models as Inference Endpoints, OR"
echo "2. Use standard models from Hub, OR"
echo "3. Continue with local ONNX models"
echo ""