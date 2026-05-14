import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/features/Auth/sign_up_page.dart';

import '../home/presentation/view/home_view.dart';
import '../home/presentation/view/main_view.dart';
import 'forget_password.dart';
import 'google_sign_in.dart';

class SignInPage extends StatefulWidget {
  static const String routeName = '/SignIn';

   const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isNotVisible = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Center(
              child: Stack(
                alignment: Alignment.topCenter,

                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    painter: LoginBorderPainter(),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      width: width * 0.9,
                      height: height * 0.82,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: height * 0.01),

                            /// TITLE
                            Text(
                              'Hello Again!',
                              style: TextStyle(
                                fontSize: width * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              'welcome Back You\'ve Been Missed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff666666),
                              ),
                            ),

                            TextFormField(
                              controller: email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please, enter your email";
                                }

                                String pattern =
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

                                RegExp regex = RegExp(pattern);

                                if (!regex.hasMatch(value)) {
                                  return "Please, enter a valid email";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff4A90E2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xff4A90E2), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xff4A90E2),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            /// PASSWORD
                            TextFormField(
                              controller: password,
                              obscureText: isNotVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "please, Enter your password";
                                }

                                if (value.length < 6) {
                                  return "please, should be at least 6 char";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    changePasswordVisible(!isNotVisible);

                                    setState(() {});
                                  },
                                  icon: Icon(
                                    isNotVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff4A90E2),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xff4A90E2), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xff4A90E2),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            /// RECOVERY PASSWORD
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ForgetPasswordPage.routeName,
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Recovery password',
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff666666),
                                  ),
                                ),
                              ),
                            ),

                            /// SIGN IN BUTTON
                            GestureDetector(
                              onTap: () async {
                                if (formkey.currentState!.validate()) {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                  )
                                      .then((data) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Login successful"),
                                        content: Text(
                                          "Welcome ${data.user!.email}",
                                        ),
                                      ),
                                    );

                                    Navigator.pushReplacementNamed(
                                      context,
                                      HomeView.routeName,
                                    );
                                  }).catchError((error) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const AlertDialog(
                                        title: Text("Login unsuccessful"),
                                        content: Text(
                                          "Please check your email or password.",
                                        ),
                                      ),
                                    );
                                  });
                                }
                              },
                              child: Container(
                                height: height * 0.065,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xff4A90E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: width * 0.055,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// OR SIGN IN
                            Text(
                              "Or SignIn",
                              style: TextStyle(
                                color: const Color(0xff666666),
                                fontSize: width * 0.04,
                              ),
                            ),

                            /// GOOGLE SIGN IN
                            ElevatedButton(
                              onPressed: () async {
                                await AuthWithGoogle.signInWithGoogle(context);
                                Navigator.pushNamed(context, MainView.routeName);

                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/images/search.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  SizedBox(width: width * 0.08),
                                  Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// SIGN UP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: const Color(0xff666666),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      SignUpPage.routeName,
                                    );
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: width * 0.035,
                                      color: const Color(0xff666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -20,
                    left: width * 0.32,
                    child: Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void changePasswordVisible(bool visible) {
    if (isNotVisible == visible) {
      return;
    } else {
      isNotVisible = visible;
    }
  }
}

/// CUSTOM BORDER
class LoginBorderPainter extends CustomPainter {
  @override
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double radius = 20;

    // بنحدد بداية ونهاية الفتحة بناءً على حجم النص تقريباً
    double gapWidth = size.width * 0.27;
    double startGap = (size.width - gapWidth) / 2;
    double endGap = startGap + gapWidth;

    // ابدأ من بعد الفتحة يميناً
    path.moveTo(endGap, 0);
    path.lineTo(size.width - radius, 0);

    // الزاوية فوق يمين
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // الخط اليمين
    path.lineTo(size.width, size.height - radius);

    // الزاوية تحت يمين
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // الخط اللي تحت
    path.lineTo(radius, size.height);

    // الزاوية تحت شمال
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // الخط اللي شمال
    path.lineTo(0, radius);

    // الزاوية فوق شمال
    path.quadraticBezierTo(0, 0, radius, 0);

    // كمل لحد بداية الفتحة
    path.lineTo(startGap, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}