import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/home/presentation/view/home_view.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_view.dart';
import 'package:graduation_app/features/writing_practice/presentation/view/writing_practice_screen.dart';
import 'package:graduation_app/features/writing_practice/presentation/cubit/writing_practice_cubit.dart';
import 'package:graduation_app/features/writing_practice/data/repos/writing_practice_repo_impl.dart';
import 'package:graduation_app/core/services/gemini_service.dart';

class MainViewBody extends StatelessWidget {
  const MainViewBody({super.key, required this.currentIndex});
  final int currentIndex ;
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentIndex,
      children: [
        const HomeView(), 
        const ChatPracticeView(), 
        BlocProvider(
          create: (context) => WritingPracticeCubit(
            WritingPracticeRepositoryImpl(context.read<GeminiService>()),
          ),
          child: const WritingPracticeScreen(),
        )
      ],
    );
  }
}
