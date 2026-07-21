import 'package:flutter/material.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
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
              _buildNavItem(1, 'Chat', Icons.chat_bubble_outline, Icons.chat_bubble),
              _buildPlusButton(context),
              _buildNavItem(2, 'Writing', Icons.edit_outlined, Icons.edit),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? ColorsManager.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : ColorsManager.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : ColorsManager.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: ColorsManager.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
