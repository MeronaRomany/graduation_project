import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/route_management/app_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/Auth/auth_wrapper.dart';

class GraduationApp extends StatelessWidget {
  const GraduationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final themeData =
            state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Graduation App',
          theme: themeData,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          onGenerateRoute: AppRouter.generateRoute,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
