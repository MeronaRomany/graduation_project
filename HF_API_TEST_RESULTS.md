# Hugging Face API Test Results

## Test Date: June 14, 2026

## Token Validation
✅ **Token is valid** - User: urewo

## Custom Models Status

### TTS Model: `boules123/speecht5-finetuned-commonvoice`
- **Status**: ✅ Model exists
- **Architecture**: WhisperForConditionalGeneration
- **Model Type**: whisper (STT, not TTS)
- **Inference API Support**: ❌ Not supported by hf-inference provider

### STT Model: `boules123/Boulesvc`
- **Status**: ✅ Model exists
- **Architecture**: WhisperForConditionalGeneration
- **Model Type**: whisper (STT)
- **Inference API Support**: ❌ Not supported by hf-inference provider

## Key Findings

1. **Both models are Whisper (STT) models**, not TTS/STT as intended
2. **Custom models are not supported** by the Hugging Face Inference API (serverless)
3. **Models need to be deployed** as Inference Endpoints to be accessible via API

## Recommendations

### Option 1: Deploy as Inference Endpoints (Recommended)
1. Go to https://huggingface.co/boules123/speecht5-finetuned-commonvoice
2. Click "Deploy" > "Inference Endpoints"
3. Configure GPU/CPU based on your needs
4. Use the endpoint URL in your app

### Option 2: Use Standard Models
For production use, consider using well-supported models:

**For STT (Speech-to-Text):**
- `openai/whisper-large-v3` - High accuracy
- `openai/whisper-small` - Faster, lower accuracy

**For TTS (Text-to-Speech):**
- `hexgrad/Kokoro-82M` - Popular, good quality
- `microsoft/speecht5_tts` - Microsoft's TTS model

### Option 3: Continue with Local ONNX Models
The app already has local ONNX models implemented:
- `assets/models/stt_whisper_quant.onnx` - Local STT
- `assets/models/tts_vits_quant.onnx` - Local TTS

Benefits:
- No API latency
- Works offline
- No token required

## API Endpoint Changes

The Hugging Face API has been updated:
- **Old endpoint**: `https://api-inference.huggingface.co/models/{model_id}`
- **New endpoint**: `https://router.huggingface.co/hf-inference/models/{model_id}`

## Files Updated
- `lib/core/services/voice_ai_service.dart` - Updated API endpoint
- `test_hf_complete.sh` - Comprehensive test script
- `test_hf_api.dart` - Dart test script

## Next Steps
1. Decide which approach to use (Endpoints, Standard Models, or Local)
2. If using Endpoints, deploy the custom models
3. Update the app to use the chosen approach
4. Test thoroughly before production deployment