import 'package:flutter/material.dart';
import 'package:graduation_app/features/profile/presentation/view/widgets/profile_view_body.dart';

class ProfileView extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ProfileViewBody(),
    );
  }
}
