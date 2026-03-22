import 'package:flutter/material.dart';
import 'package:graduation_app/features/home/presentation/view/main_view.dart';
import '../features/Auth/forget_password.dart';
import '../features/Auth/sign_in_page.dart';
import '../features/Auth/sign_up_page.dart';
import '../features/home/presentation/view/home_view.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case SignInPage.routeName:
        return MaterialPageRoute(builder: (_) => SignInPage());
      case SignUpPage.routeName:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case ForgetPasswordPage.routeName:
        return MaterialPageRoute(builder: (_) => ForgetPasswordPage());
      case HomeView.routeName:
        return MaterialPageRoute(builder: (_) => HomeView());
      case MainView.routeName:
        return MaterialPageRoute(builder: (_) => MainView());

    }
    return null;
  }
}
