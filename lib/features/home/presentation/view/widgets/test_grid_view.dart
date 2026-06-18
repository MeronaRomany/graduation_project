import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/test_component.dart';
import 'package:graduation_app/route_management/app_router.dart';

class TestsGridView extends StatelessWidget {
  const TestsGridView({
    super.key,
  });

  final List<String> testNames = const [
    'Speak with AI',
    'English Shadowing',
    'IELTS Preparation',
    'TOEFL Preparation',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
    itemCount: testNames.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.67 ,
    ),
    itemBuilder: (context, index) {
      return TestComponent(
        text: testNames[index],
        isCompleted: index == 0 || index == 1,
        onTap: index == 0 ? () {
          Navigator.pushNamed(context, AppRouter.aiSpeaker);
        } : null,
      );
    } 
    
    );
  }
}
