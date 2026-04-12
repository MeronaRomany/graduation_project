import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/core/utils/assets.dart';

class HeaderDelegate extends StatelessWidget {
  const HeaderDelegate({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find a Partner",
                style: AppTextStyles.bold19.copyWith(color: Color(0xffDB2777)),
              ),
              Text(
                "YOUR LEVEL: B2 INTERMEDIATE",
                style: AppTextStyles.regular11,
              ),
            ],
          ),
          const CircleAvatar(
            backgroundImage: AssetImage(Assets.assetsImagesPersonalAvatar),
            radius: 20,
          ),
        ],
      ),
    );
  }
}
