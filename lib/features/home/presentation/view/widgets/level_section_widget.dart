import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/level_component.dart';

class LevelSectionWidget extends StatelessWidget {
  const LevelSectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Level',
          style: AppTextStyles.regular26.copyWith(
              fontFamily: Assets.resourceFontsPatrickHandSCRegular),
        ),
        SizedBox(
          height: 2,
        ),
        Container(
          height: 1,
          width: 38,
          decoration: BoxDecoration(
              color: AppColors.primaryColor ,
              borderRadius: BorderRadius.circular(24)),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'A1.1',
              style: AppTextStyles.regular20,
            ),
          ),
        ),
        SizedBox(height: 4,),
        LevelComponent(
          text: 'Keywords you \nmust know',
          backgroundImage: Assets.resourceImagesHollowRightMark,
          image: Assets.resourceImagesRightMark,
          numOfLevel: 1,
        ),
                      
        SizedBox(height: 16,),
                      
        LevelComponent(
          text: 'Keywords you \nmust know',
          backgroundImage: Assets.resourceImagesHollowPlayButton,
          image: Assets.resourceImagesPlayButton,
          numOfLevel: 2,
        ),
        SizedBox(height: 22,),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'A1.2',
              style: AppTextStyles.regular20,
            ),
          ),
        ),
        SizedBox(height: 4,),
        LevelComponent(
          text: 'Keywords you \nmust know',
          backgroundImage: Assets.resourceImagesHollowPlayButton,
          image: Assets.resourceImagesPlayButton,
          numOfLevel: 3,
        ),
                      
        SizedBox(height: 16,),
                      
        LevelComponent(
          text: 'Keywords you \nmust know',
          backgroundImage: Assets.resourceImagesHollowPlayButton,
          image: Assets.resourceImagesPlayButton,
          numOfLevel: 4,
        ),
      ],
    );
  }
}
