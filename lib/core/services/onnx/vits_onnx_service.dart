import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'onnx_service.dart';

class VITSOnnxService extends OnnxService {
  VITSOnnxService() : super('assets/models/tts_vits_quant.onnx');

  Future<Float32List> generateSpeech(String text) async {
    if (session == null) await init();

    try {
      final inputIds = _textToIds(text.trim());
      if (inputIds.isEmpty) return Float32List(0);

      final inputNames = session!.inputNames;
      final inputCount = inputNames.length;

      final Map<String, OrtValue> inputs = {};

      final Int64List inputIdsInt64 = Int64List.fromList(inputIds);
      final inputIdsTensor = await OrtValue.fromList(
        inputIdsInt64,
        [1, inputIds.length],
      );

      if (inputCount == 1) {
        inputs[inputNames[0]] = inputIdsTensor;
      } else if (inputCount == 2) {
        inputs[inputNames[0]] = inputIdsTensor;

        final Int64List maskInt64 = Int64List.fromList(List.filled(inputIds.length, 1));
        inputs[inputNames[1]] = await OrtValue.fromList(
          maskInt64,
          [1, inputIds.length],
        );
      } else {
        inputs['input_ids'] = inputIdsTensor;
        if (inputNames.contains('attention_mask')) {
          final Int64List maskInt64 = Int64List.fromList(List.filled(inputIds.length, 1));
          inputs['attention_mask'] = await OrtValue.fromList(
            maskInt64,
            [1, inputIds.length],
          );
        }
        if (inputNames.contains('noise_scale')) {
          inputs['noise_scale'] = await OrtValue.fromList([0.667], [1]);
        }
        if (inputNames.contains('length_scale')) {
          inputs['length_scale'] = await OrtValue.fromList([1.0], [1]);
        }
        if (inputNames.contains('noise_scale_w')) {
          inputs['noise_scale_w'] = await OrtValue.fromList([0.8], [1]);
        }
      }

      final outputs = await session!.run(inputs);
      final audioTensor = outputs.values.first;
      final raw = await audioTensor.asList();

      return Float32List.fromList(
        raw.map((e) => (e as num).toDouble()).toList(),
      );
    } catch (e) {
      throw Exception("VITS error: $e");
    }
  }

  List<int> _textToIds(String text) {
    const Map<String, int> symbolMap = {
      ' ': 3, '!': 4, "'": 5, ',': 7, '-': 8, '.': 9,
      ':': 13, ';': 14, '?': 16,
      'a': 20, 'b': 21, 'c': 22, 'd': 23, 'e': 24, 'f': 25,
      'g': 26, 'h': 27, 'i': 28, 'j': 29, 'k': 30, 'l': 31,
      'm': 32, 'n': 33, 'o': 34, 'p': 35, 'q': 36, 'r': 37,
      's': 38, 't': 39, 'u': 40, 'v': 41, 'w': 42, 'x': 43,
      'y': 44, 'z': 45,
      'A': 20, 'B': 21, 'C': 22, 'D': 23, 'E': 24, 'F': 25,
      'G': 26, 'H': 27, 'I': 28, 'J': 29, 'K': 30, 'L': 31,
      'M': 32, 'N': 33, 'O': 34, 'P': 35, 'Q': 36, 'R': 37,
      'S': 38, 'T': 39, 'U': 40, 'V': 41, 'W': 42, 'X': 43,
      'Y': 44, 'Z': 45,
    };

    return text.split('')
        .map((c) => symbolMap[c])
        .whereType<int>()
        .toList();
  }
}
