import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class LevelComponent extends StatelessWidget {
  const LevelComponent({super.key, required this.text, required this.numOfLevel, required this.backgroundImage, required this.image});
  final int numOfLevel;
  final String text;
  final String backgroundImage , image;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 353,
          decoration: BoxDecoration(
            border: BoxBorder.all(width: 1, color: AppColors.primaryColor),
            color: Color(0xFFFFFFFF).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Row(
                children: [
                  Text(numOfLevel.toString() , style: AppTextStyles.bold19 ,),
                  SizedBox(width: 16,) ,
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular20 ,
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      Image.asset(backgroundImage),
                      Positioned(bottom:4 , left: 3 , child: Image.asset(image)),
                    ],
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ),
          ),
        );
  }
}