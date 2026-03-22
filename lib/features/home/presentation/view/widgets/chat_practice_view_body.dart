import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/core/utils/assets.dart';

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
          image: AssetImage(Assets.resourceImagesBackground),
          fit: BoxFit.fill,
        )),
          child: Stack(
            children: [
                
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    const HeaderDelegate(),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    const SliverToBoxAdapter(child: LevelFilterSection()),
                    const SliverToBoxAdapter(child: SectionHeader(title: "Online Now", count: 24)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const UserCard(),
                        childCount: 4,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SectionHeader(title: "Icebreakers")),
                    const SliverToBoxAdapter(child: IcebreakerGrid()),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
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


// --- Glass Card Component ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? gradientColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(4),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withAlpha(5), width: 0.5),
              gradient: gradientColor != null 
                ? LinearGradient(
                    colors: [gradientColor!.withAlpha(2), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) 
                : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --- Specific UI Sections ---

class HeaderDelegate extends StatelessWidget {
  const HeaderDelegate({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find a Partner",
                    style:AppTextStyles.regular20.copyWith(color: Color(0xffDB2777) ),
                  ),
                  const Text(
                    "YOUR LEVEL: B2 INTERMEDIATE",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                radius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Stack(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white54),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF00EFA0)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Marc", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("C1 Advanced", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {}, // Trigger Agora Call here
            icon: const Icon(Icons.mic, size: 18),
            label: const Text("Join Call"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              foregroundColor: const Color(0xFFB5005B),
              elevation: 0,
              shape: const StadiumBorder(),
            ),
          )
        ],
      ),
    );
  }
}

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(7),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(1), blurRadius: 40)],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.search, color: Color(0xFFB5005B)),
          Icon(Icons.chat_bubble_outline, color: Colors.grey),
          Icon(Icons.video_call_outlined, color: Colors.grey),
          Icon(Icons.person_outline, color: Colors.grey),
        ],
      ),
    );
  }
}

// Simplified placeholders for remaining sections
class LevelFilterSection extends StatelessWidget {
  const LevelFilterSection({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 50, child: Center(child: Text("Filter Chips Go Here")));
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const SectionHeader({super.key, required this.title, this.count});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Text(title.toUpperCase(), style: const TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class IcebreakerGrid extends StatelessWidget {
  const IcebreakerGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      gradientColor: Colors.blue,
      child: Text("Icebreaker Content"),
    );
  }
}