import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

abstract class OnnxService {
  String modelPath;

  OrtSession? session;

  final OnnxRuntime _ort =
  OnnxRuntime();

  OnnxService(this.modelPath);

  Future<void> init() async {
    session =
    await _ort.createSession(modelPath);
  }

  Future<void> dispose() async {
    await session?.close();
    session = null;
  }
}