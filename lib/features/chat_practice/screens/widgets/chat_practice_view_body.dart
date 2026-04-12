import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/floating_bottom_nav.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/header_deleget.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/ice_breaker_row.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/section_header.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/user_card.dart';

class ChatPracticeViewBody extends StatelessWidget {
  const ChatPracticeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
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
                      const SliverToBoxAdapter(
                          child: SectionHeader(title: "Online Now", count: 24)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const UserCard(),
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
