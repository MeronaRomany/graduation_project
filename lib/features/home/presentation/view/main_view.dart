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
    return Scaffold(
      body: Stack(
        children: [
          MainViewBody(currentIndex: currentIndex),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavigationBar(
                index: currentIndex,
                onItemTapped: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
