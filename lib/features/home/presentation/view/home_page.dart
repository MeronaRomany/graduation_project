import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import '../bloc/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'home_title'.tr(),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6_outlined),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              tooltip: 'toggle_theme'.tr(),
            ),
          ],
        ),
        drawer: const CustomDrawer(),
        body: Center(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return CustomCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('counter_value'.tr(args: [state.counter.toString()])),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<HomeCubit>().increment(),
                      icon: const Icon(Icons.add),
                      label: Text('increment'.tr()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
