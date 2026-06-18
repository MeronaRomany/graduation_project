import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/Auth/sign_in_page.dart';
import 'package:graduation_app/route_management/app_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/Auth/auth_wrapper.dart';

class GraduationApp extends StatelessWidget {

 const GraduationApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final themeData =
            state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Graduation App',
            builder: (context, child) {
              final locale = context.locale;
              final isEnglish = locale.languageCode == 'en';
              return Directionality(
                textDirection:
                isEnglish ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: child!,
              );
            },
            theme: themeData,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            
            onGenerateRoute:AppRouter.generateRoute,

            home : AuthWrapper(),
          ),
        );
      },
    );
  }
}
