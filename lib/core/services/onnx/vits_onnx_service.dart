import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'onnx_service.dart';

class VITSOnnxService extends OnnxService {
  final String vocabPath;
  final String? tokenizerConfigPath;
  final String? addedTokensPath;

  late Map<String, int> vocab;

  VITSOnnxService(
      super.path,
      this.vocabPath, {
        this.tokenizerConfigPath,
        this.addedTokensPath,
      });

  Future<void> initVocab() async {
    final file = File(vocabPath);
    final jsonMap = jsonDecode(await file.readAsString());

    vocab = Map<String, int>.from(
      jsonMap.map(
            (k, v) => MapEntry(
          k.toString(),
          (v is int)
              ? v
              : int.tryParse(v.toString()) ?? 0,
        ),
      ),
    );
    if (tokenizerConfigPath != null) {
      final config = jsonDecode(await File(tokenizerConfigPath!).readAsString());
      print("Tokenizer config loaded: $config");
    }

    if (addedTokensPath != null) {
      final added = jsonDecode(await File(addedTokensPath!).readAsString());
      print("Added tokens loaded: $added");
    }
  }

  List<int> _encode(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map((w) => vocab[w] ?? 0)
        .toList();
  }

  Future<Float32List> generateSpeech(String text) async {
    if (session == null) await init();

    final inputIds = _encode(text);

    final inputTensor = await OrtValue.fromList(
      Int64List.fromList(inputIds),
      [1, inputIds.length],
    );

    final inputs = <String, OrtValue>{
      'input_ids': inputTensor,
      'attention_mask': await OrtValue.fromList(
        List.filled(inputIds.length, 1),
        [1, inputIds.length],
      ),
      'noise_scale': await OrtValue.fromList([0.667], [1]),
      'length_scale': await OrtValue.fromList([1.0], [1]),
      'noise_scale_w': await OrtValue.fromList([0.8], [1]),
    };

    final outputs = await session!.run(inputs);
    final audio = outputs.values.first;

    final raw = await audio.asList();

    return Float32List.fromList(
      raw.map((e) => (e as num).toDouble()).toList(),
    );
  }
}