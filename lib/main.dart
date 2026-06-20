import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app/app.dart';

import 'core/services/gemini_service.dart';
import 'core/services/speech_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/hf_spaces_service.dart';

import 'core/theme/theme_cubit.dart';
import 'features/ai_model_speaker/presentation/bloc/conversation_bloc.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // HF Spaces cloud service
  final hfSpacesService = HfSpacesService();
  debugPrint("HF Spaces service ready ✅");

  // Speech & TTS services (cloud primary)
  final speechService = SpeechService(
    hfSpacesService,
  );
  debugPrint("Speech service ready ✅");

  final ttsService = TTSService(
    hfSpacesService,
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
