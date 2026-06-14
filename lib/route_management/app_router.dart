import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/ai_model_speaker/presentation/view/ai_model_speaker.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_audio_screen.dart';
import 'package:graduation_app/features/home/presentation/view/main_view.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:graduation_app/features/profile/presentation/view/edit_profile_view.dart';
import 'package:graduation_app/features/profile/presentation/view/help_support_view.dart';
import 'package:graduation_app/features/profile/presentation/view/my_progress_view.dart';
import 'package:graduation_app/features/profile/presentation/view/profile_view.dart';
import 'package:graduation_app/features/profile/presentation/view/settings_view.dart';
import '../features/Auth/forget_password.dart';
import '../features/Auth/sign_in_page.dart';
import '../features/Auth/sign_up_page.dart';
import '../features/home/data/models/role_play_scenario.dart';
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
        final args = setting.arguments;
        RolePlayScenario? scenario;
        if (args is RolePlayScenario) {
          scenario = args;
        } else if (args is String) {
          scenario = RolePlayScenario(
            id: 'custom',
            title: args,
            description: 'Custom scenario',
            emoji: '✨',
            systemPrompt:
                'You are a roleplay partner. The user wants to practice English about: $args. '
                    'Start a natural conversation about this topic.',
            starterMessage: '',
            difficulty: DifficultyLevel.intermediate,
            category: ScenarioCategory.dailyLife,
            cefrLevel: CefrLevel.b12,
          );
        }
        return MaterialPageRoute(
          builder: (_) => AIModelSpeakerScreen(scenario: scenario),
        );
      case ProfileView.routeName:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case EditProfileView.routeName:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit()..loadUserProfile(),
            child: const EditProfileView(),
          ),
        );
      case SettingsView.routeName:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case MyProgressView.routeName:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit()..loadUserProfile(),
            child: const MyProgressView(),
          ),
        );
      case HelpSupportView.routeName:
        return MaterialPageRoute(builder: (_) => const HelpSupportView());
    }
    return null;
  }
}
