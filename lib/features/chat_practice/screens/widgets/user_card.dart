import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/glass_card.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Marc",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("C1 Advanced", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mic_none_outlined, size: 18),
            label: const Text("Join Call"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(247, 255, 255, 255),
              foregroundColor: const Color(0xFFB5005B),
              shadowColor: Colors.black,
              elevation: .01,
              shape: const StadiumBorder(),
            ),
          )
        ],
      ),
    );
  }
}
