import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_audio_screen.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_cubit.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_state.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/glass_card.dart';
import 'package:graduation_app/models/user_model_auth.dart';
import 'package:graduation_app/core/utils/app_colors.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white54,
                backgroundImage: AssetImage(Assets.assetsImagesMarc),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 6,
                    backgroundColor: Color(0xFF00EFA0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name.isEmpty ? "User" : user.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                Text(user.level.isEmpty ? "Level" : user.level, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          BlocBuilder<ChatPracticeCubit, ChatPracticeState>(
            builder: (context, state) {
              final isLoading = state.status == CallStatus.loading;
              return ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        final currentCubit = context.read<ChatPracticeCubit>();
                        await currentCubit.initChat();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                      value: currentCubit,
                                      child: const ChatPracticeAudioScreen(
                                        localUserId: '',
                                      ),
                                    )
                            ),
                          );
                        }
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : const Icon(Icons.mic_none_outlined, size: 18),
                label: Text(isLoading ? "Joining..." : "Join Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(247, 255, 255, 255),
                  foregroundColor: AppColors.primaryColor,
                  shadowColor: Colors.black,
                  elevation: .01,
                  shape: const StadiumBorder(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
