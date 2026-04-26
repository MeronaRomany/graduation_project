import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

abstract class OnnxService {
  OrtSession? session;
  final String modelPath;

  OnnxService(this.modelPath);

  Future<void> init() async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    
    // Copy model from assets to local storage if needed
    final modelFile = await _getModelFile();
    session = OrtSession.fromFile(modelFile, sessionOptions);
  }

  Future<File> _getModelFile() async {
    final byteData = await rootBundle.load(modelPath);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${modelPath.split('/').last}');
    
    if (!await file.exists()) {
      await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file;
  }

  void dispose() {
    session?.release();
  }
}
