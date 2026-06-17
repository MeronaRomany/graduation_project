import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/home_view_title_row.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/role_play_grid_view.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/test_grid_view.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(Assets.assetsImagesBackground),
              fit: BoxFit.fill,
            )),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeViewTitleRow(),
                      const SizedBox(height: 20),
                      const TestsGridView(), // Main Feature Cards
                      const SizedBox(height: 32),
                      const RolePlayGridView(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
