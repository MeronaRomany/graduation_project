import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/chat_practice/data/repos/chat_practice_repo_impl.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_cubit.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/chat_practice_view_body.dart';
import 'package:graduation_app/services/firestore_service.dart';

class ChatPracticeView extends StatelessWidget {
  const ChatPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatPracticeCubit(
          ChatPracticeRepositoryImpl(fireStoreService: FireStoreService())),
      child: Scaffold(body: const ChatPracticeViewBody()),
    );
  }
}
