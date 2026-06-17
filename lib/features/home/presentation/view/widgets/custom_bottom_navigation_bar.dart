import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/custom_scenario_bottom_sheet.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar(
      {super.key, this.onItemTapped, required this.index});

  final Function(int)? onItemTapped;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            textDirection: TextDirection.ltr,
            children: [
              _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home),
              _buildNavItem(1, 'Writing', Icons.edit_note, Icons.edit_note),
              _buildPlusButton(context),
              _buildNavItem(3, 'Chat', Icons.chat_bubble_outline, Icons.chat_bubble),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int itemIndex, String label, IconData icon, IconData activeIcon) {
    bool isSelected = index == itemIndex;
    return Flexible(
      child: GestureDetector(
        onTap: () => onItemTapped?.call(itemIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : AppColors.primaryColor,
                size: 20,
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlusButton(BuildContext context) {
    return GestureDetector(
      onTap: () => CustomScenarioBottomSheet.show(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
