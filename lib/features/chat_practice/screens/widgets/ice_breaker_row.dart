import 'package:flutter/material.dart';
import 'package:graduation_app/features/chat_practice/screens/widgets/ice_breaker_widget.dart';

class IcebreakerRow extends StatelessWidget {
  const IcebreakerRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IceBreakerWidget(
          title: "Dream Destinations",
          subtitle:
              "Practice future tense by discussing where you'd travel next",
          icon: Icons.travel_explore_outlined,
          color: Color(0xff00576C),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: IceBreakerWidget(
              title: "Movie Night",
              subtitle: "Talk about your favorite movies and TV shows.",
              icon: Icons.movie_outlined,
              color: Color.fromARGB(255, 5, 231, 152),
            )),
            SizedBox(width: 16),
            Expanded(
                child: IceBreakerWidget(
              title: "Local Food",
              subtitle: "Describe your favorite meal.",
              icon: Icons.restaurant,
              color: Color(0xffB5005B),
            )),
          ],
        )
      ],
    );
  }
}
