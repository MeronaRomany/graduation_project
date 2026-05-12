import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_cubit.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_state.dart';

class ChatPracticeAudioScreen extends StatelessWidget {
  static const String routeName = "ChatPracticeAudioScreen";
  final String localUserId;

  const ChatPracticeAudioScreen({super.key, required this.localUserId});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: BlocConsumer<ChatPracticeCubit, ChatPracticeState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.errMessage != null && state.errMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errMessage!)),
              );
            }
            if (state.status == CallStatus.ended || state.status == CallStatus.failed) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            final remoteUser = state.remoteUser;
            final localUser = state.localUser;

            return Stack(
              children: [
                // Remote User Info (Center)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade800,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: state.remoteLevelOfAudio > 10 ? Colors.green : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        remoteUser?.name ?? 'Waiting for matched user...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.status == CallStatus.connected 
                            ? _formatDuration(state.duration) 
                            : state.status.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Local User Info (Top Right)
                if (localUser != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            localUser.name,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade700,
                            child: const Icon(Icons.person, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Controls (Bottom)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mute/Unmute
                      GestureDetector(
                        onTap: () => context.read<ChatPracticeCubit>().toggleMute(),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: state.isMuted ? Colors.white : Colors.grey.shade800,
                          child: Icon(
                            state.isMuted ? Icons.mic_off : Icons.mic,
                            color: state.isMuted ? Colors.black : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Leave Call
                      GestureDetector(
                        onTap: () {
                          context.read<ChatPracticeCubit>().leaveCall(localUserId);
                        },
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.redAccent,
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
