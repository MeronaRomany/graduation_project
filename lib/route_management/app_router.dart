import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/Auth/forget_password.dart';
import '../features/Auth/sign_in_page.dart';
import '../features/Auth/sign_up_page.dart';
import '../features/home/presentation/view/home_page.dart';

class AppRouter{

 static Route? generateRoute(RouteSettings setting){
    switch(setting.name){
      case "signIn":
        return MaterialPageRoute(builder: (_)=>SignInPage());

      case "Signup":
        return MaterialPageRoute(builder: (_)=>SignUpPage());
      case "forgetPassword":
        return MaterialPageRoute(builder: (_)=>ForgetPasswordPage());
      case "homePage":
        return MaterialPageRoute(builder: (_)=>HomePage());
    }
    return null;
  }
}