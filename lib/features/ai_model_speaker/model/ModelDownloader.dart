import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static const String token="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";
  static const whisperUrl =
      'https://huggingface.co/boules123/voice-ai-models/resolve/main/stt/whisper_encoder.onnx';

  static const vitsUrl =
      'https://huggingface.co/boules123/voice-ai-models/resolve/main/tts/vits_tts.onnx';

  static const addToken="https://huggingface.co/boules123/voice-ai-models/resolve/main/tts/tokenizer/added_tokens.json";
  static const token_config='https://huggingface.co/boules123/voice-ai-models/resolve/main/tts/tokenizer/tokenizer_config.json';

  static const vocab='https://huggingface.co/boules123/voice-ai-models/resolve/main/tts/tokenizer/vocab.json';
  static Future<String> downloadModel(
      String url,
      String fileName,
      ) async {
    final dir = await getApplicationDocumentsDirectory();

    final modelsDir =
    Directory('${dir.path}/models');

    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    final file =
    File('${modelsDir.path}/$fileName');

    if (await file.exists()) {
      return file.path;
    }

    final dio = Dio();

    final response = await dio.get(
      url,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
        responseType: ResponseType.bytes,
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Download failed ${response.statusCode}');
    }

    await file.writeAsBytes(response.data);

    return file.path;
  }
}