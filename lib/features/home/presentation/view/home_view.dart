import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/home/presentation/view/widgets/home_view_body.dart';
import '../bloc/home_cubit.dart';

class HomeView extends StatelessWidget {

  static const String routeName = '/home';
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
        create: (_) => HomeCubit(),
        child: HomeViewBody(),
      );
  }
}