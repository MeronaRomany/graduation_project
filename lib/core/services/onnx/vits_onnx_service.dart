import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'onnx_service.dart';

class VITSOnnxService extends OnnxService {
  VITSOnnxService() : super('assets/models/tts_vits_quant.onnx');

  Future<Float32List> generateSpeech(String text) async {
    if (session == null) await init();

    // VITS ONNX usually expects:
    // 1. input: [1, sequence_length] int64 (phoneme IDs)
    // 2. input_lengths: [1] int64
    // 3. scales: [3] float32 (noise_scale, length_scale, noise_scale_w)

    // Simplified input mapping for now
    final inputIds = _textToIds(text);
    final inputOrt = await OrtValue.fromList(
      inputIds,
      [1, inputIds.length],
    );

    final inputs = {'input': inputOrt};
    final outputs = await session.run(inputs);

    // Get audio output - the output name depends on the model
    final outputTensor = outputs.values.first;
    final audioOutput = await outputTensor.asList();

    if (audioOutput == null || audioOutput.isEmpty) {
      throw Exception('VITS output is null or empty');
    }

    // Convert to Float32List
    final samples = audioOutput.cast<double>();
    final flatAudio = Float32List.fromList(samples);

    return flatAudio;
  }

  List<int> _textToIds(String text) {
    // Basic char-to-id mapping as a placeholder
    // Real VITS needs a phonemizer
    return text.codeUnits.map((e) => e % 100).toList();
  }
}
