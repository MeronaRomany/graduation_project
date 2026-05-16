import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/home_view.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_view.dart';

class MainViewBody extends StatelessWidget {
  const MainViewBody({super.key, required this.currentIndex});
  final int currentIndex ;
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index:currentIndex == 2 ? 2 : 0,
      children: const [HomeView(), ChatPracticeView()],
    );
  }
}
