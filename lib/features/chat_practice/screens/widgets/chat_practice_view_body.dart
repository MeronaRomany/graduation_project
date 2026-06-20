import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_cubit.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_state.dart';
import 'package:graduation_app/features/chat_practice/screens/chat_practice_audio_screen.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/floating_bottom_nav.dart';
import 'package:graduation_app/features/chat_practice/data/repos/chat_practice_repo_impl.dart';
import 'package:graduation_app/services/firestore_service.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/header_deleget.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/ice_breaker_row.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/section_header.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/user_card.dart';
import 'package:graduation_app/models/user_model_auth.dart';

class ChatPracticeViewBody extends StatelessWidget {
  const ChatPracticeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatPracticeCubit>();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBody: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(Assets.assetsImagesBackground),
            fit: BoxFit.fill,
          )),
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: CustomScrollView(
                    slivers: [
                      const HeaderDelegate(),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverToBoxAdapter(
                         child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: BlocBuilder<ChatPracticeCubit, ChatPracticeState>(
                              builder: (context, state) {
                                final isLoading = state.status == CallStatus.loading;
                                return ElevatedButton.icon(
                                  onPressed: isLoading ? null : () async {
                                      final currentCubit = context.read<ChatPracticeCubit>();
                                      await currentCubit.enterWaitingState(null);
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: currentCubit,
                                              child: const ChatPracticeAudioScreen(localUserId: ''),
                                            ),
                                          ),
                                        );
                                      }
                                  },
                                  icon: isLoading 
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                      : const Icon(Icons.people),
                                  label: Text(isLoading ? "Joining Waiting Room..." : "Enter Waiting State"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB5005B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            ),
                         ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      StreamBuilder<List<UserModel>>(
                        stream: FireStoreService().getWaitingUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: CircularProgressIndicator(color: Colors.white)),
                              ),
                            );
                          }
                          final List<UserModel> users = List.from(snapshot.data ?? []);
                          const dummyUser = UserModel(uid: 'dummy_afraym', name: 'Afraym Herz', email: '', level: 'B1');
                          if (!users.any((u) => u.uid == dummyUser.uid)) {
                            users.insert(0, dummyUser);
                          }
                          return SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(title: "Online Now", count: users.length),
                                if (users.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: Text(
                                        "No users waiting in queue",
                                        style: TextStyle(color: Colors.white70, fontSize: 16),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: BlocProvider(
                                          create: (context) => ChatPracticeCubit(
                                              ChatPracticeRepositoryImpl(fireStoreService: FireStoreService())),
                                          child: UserCard(user: users[index]),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      const SliverToBoxAdapter(
                          child: SectionHeader(title: "Icebreakers")),
                      const SliverToBoxAdapter(child: IcebreakerRow()),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const FloatingBottomNav(),
      ),
    );
  }
}
