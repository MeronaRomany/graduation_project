import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/custom_bottom_navigation_bar.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/main_view_body.dart';

class MainView extends StatefulWidget {
  static const routeName = '/MainView';

  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // extendBody: true يسمح للمحتوى بالظهور خلف الـ Navbar العائم
      extendBody: true,
      body: MainViewBody(currentIndex: currentIndex),
      bottomNavigationBar: isKeyboardVisible
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: CustomBottomNavigationBar(
                index: currentIndex,
                onItemTapped: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
    );
  }
}
