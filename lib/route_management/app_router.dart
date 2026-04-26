import 'package:flutter/material.dart';
import 'package:graduation_app/features/ai_model_speaker/presentation/view/ai_model_speaker.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_audio_screen.dart';
import 'package:graduation_app/features/home/presentation/view/main_view.dart';
import '../features/Auth/forget_password.dart';
import '../features/Auth/sign_in_page.dart';
import '../features/Auth/sign_up_page.dart';
import '../features/home/presentation/view/home_view.dart';

class AppRouter {
  static const String aiSpeaker = '/ai-speaker';

  static Route? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case SignInPage.routeName:
        return MaterialPageRoute(builder: (_) => SignInPage());
      case SignUpPage.routeName:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case ForgetPasswordPage.routeName:
        return MaterialPageRoute(builder: (_) => ForgetPasswordPage());
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => HomeView());
      case MainView.routeName:
        return MaterialPageRoute(builder: (_) => MainView());
      case ChatPracticeAudioScreen.routeName:
        return MaterialPageRoute(builder: (_) => ChatPracticeAudioScreen(localUserId: '',));
      case aiSpeaker:
        return MaterialPageRoute(builder: (_) => const AIModelSpeakerScreen());
    }
    return null;
  }
}
