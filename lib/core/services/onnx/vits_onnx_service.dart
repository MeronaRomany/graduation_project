import 'dart:typed_data';
import 'package:onnxruntime/onnxruntime.dart';
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
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      Int64List.fromList(inputIds),
      [1, inputIds.length],
    );

    final inputs = {'input': inputOrt};
    final runOptions = OrtRunOptions();
    final outputs = session!.run(runOptions, inputs);

    inputOrt.release();
    runOptions.release();

    final audioOutput = outputs[0]?.value;
    if (audioOutput == null) throw Exception('VITS output is null');

    // Handle different possible output shapes from VITS ONNX
    List<double> samples;
    if (audioOutput is List<List<List<double>>>) {
      samples = audioOutput[0][0];
    } else if (audioOutput is List<List<double>>) {
      samples = audioOutput[0];
    } else if (audioOutput is List<double>) {
      samples = audioOutput;
    } else {
      throw Exception('Unexpected VITS output shape: ${audioOutput.runtimeType}');
    }

    final flatAudio = Float32List.fromList(samples);

    for (var element in outputs) {
      element?.release();
    }

    return flatAudio;
  }

  List<int> _textToIds(String text) {
    // Basic char-to-id mapping as a placeholder
    // Real VITS needs a phonemizer
    return text.codeUnits.map((e) => e % 100).toList();
  }
}
