import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class TestComponent extends StatelessWidget {
  const TestComponent({super.key, this.isCompleted = true, required this.text, this.onTap});
  final bool isCompleted ;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(width: 1, color: AppColors.primaryColor),
              color: Color(0xFFFFFFFF).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:16),
              child: Center(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold25 ,
                ),
              ),
            ),
          ),
         isCompleted ? Container() : Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 44,
              height: 21,
              decoration: BoxDecoration(
                  color: Color(0xFFFFF126),
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                  child: Text(
                'Soon',
                style: AppTextStyles.regular13 ,
              )),
            ),
          )
        ],
      ),
    );
  }
}
