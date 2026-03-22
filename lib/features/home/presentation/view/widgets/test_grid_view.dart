import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/test_component.dart';

class TestsGridView extends StatelessWidget {
  const TestsGridView({
    super.key,
  });

  final List<String> testNames = const [
    'English Shadowing',
    'IELTS Preparation',
    'TOEFL Preparation',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
    itemCount: 3,
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
        isCompleted: index == 0,
      );
    } 
    
    );
  }
}