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
                      const SliverToBoxAdapter(
                          child: SectionHeader(title: "Online Now", count: 24)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: BlocProvider(
                              create: (context) => ChatPracticeCubit(
                                  ChatPracticeRepositoryImpl(fireStoreService: FireStoreService())),
                              child: const UserCard(),
                            ),
                          ),
                          childCount: 4,
                        ),
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
