import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

abstract class OnnxService {
  dynamic session;
  final String modelPath;
  final OnnxRuntime _ort = OnnxRuntime();

  OnnxService(this.modelPath);

  Future<void> init() async {
    // Load model directly from assets
    session = await _ort.createSessionFromAsset(modelPath);
  }

  void dispose() {
    session?.dispose();
  }
}
