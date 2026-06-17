import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'app/app.dart';

import 'core/services/gemini_service.dart';
import 'core/services/speech_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/hf_spaces_service.dart';
import 'core/services/voice_provider.dart';

import 'core/services/onnx/vits_onnx_service.dart';
import 'core/services/onnx/whisper_onnx_service.dart';

import 'core/theme/theme_cubit.dart';
import 'features/ai_model_speaker/model/ModelDownloader.dart';
import 'features/ai_model_speaker/presentation/bloc/conversation_bloc.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize voice provider (reads saved preference)
  final voiceProvider = VoiceProviderCubit();
  await voiceProvider.init();
  debugPrint("Voice provider ready ✅");

  // HF Spaces cloud service
  final hfSpacesService = HfSpacesService();
  debugPrint("HF Spaces service ready ✅");

  // Download ONNX models
  final vocabPath = await ModelDownloader.downloadModel(
    ModelDownloader.vocab,
    'vocab.json',
  );

  final configPath = await ModelDownloader.downloadModel(
    ModelDownloader.token_config,
    'tokenizer_config.json',
  );

  final addedTokensPath = await ModelDownloader.downloadModel(
    ModelDownloader.addToken,
    'added_tokens.json',
  );

  final whisperPath = await ModelDownloader.downloadModel(
    ModelDownloader.whisperUrl,
    'whisper.onnx',
  );

  final vitsPath = await ModelDownloader.downloadModel(
    ModelDownloader.vitsUrl,
    'vits.onnx',
  );

  // Local ONNX services
  final whisperService = WhisperOnnxService(whisperPath);
  await whisperService.init();
  debugPrint("Whisper loaded ✅");

  final vitsService = VITSOnnxService(
    vitsPath,
    vocabPath,
    tokenizerConfigPath: configPath,
    addedTokensPath: addedTokensPath,
  );
  await vitsService.initVocab();
  debugPrint("VITS loaded ✅");
  debugPrint("Vocab loaded ✅");

  // Speech & TTS services (cloud primary, local fallback)
  final speechService = SpeechService(
    whisperService,
    hfSpacesService,
    voiceProvider,
  );
  debugPrint("Speech service ready ✅");

  final ttsService = TTSService(
    vitsService,
    hfSpacesService,
    voiceProvider,
  );
  await ttsService.initialize();
  debugPrint("TTS ready ✅");

  final geminiService = GeminiService();
  debugPrint("Gemini ready ✅");

  runApp(
    MultiProvider(
      providers: [
        Provider<SpeechService>.value(value: speechService),
        Provider<TTSService>.value(value: ttsService),
        Provider<GeminiService>.value(value: geminiService),
        Provider<HfSpacesService>.value(value: hfSpacesService),
        BlocProvider<VoiceProviderCubit>.value(value: voiceProvider),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConversationBloc(
              context.read<GeminiService>(),
              context.read<SpeechService>(),
              context.read<TTSService>(),
            ),
          ),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: const GraduationApp(),
        ),
      ),
    ),
  );
}
