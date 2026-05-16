import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

abstract class OnnxService {
  final String modelPath;
  OrtSession? session;

  final OnnxRuntime _ort = OnnxRuntime();

  OnnxService(this.modelPath);

  Future<void> init() async {
    try {
      // flutter_onnxruntime API: no OrtSessionOptions needed
      session = await _ort.createSessionFromAsset(modelPath);
    } catch (e) {
      print('Failed to initialize ONNX model at $modelPath: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await session?.close();
    } catch (_) {}
    session = null;
  }
}
