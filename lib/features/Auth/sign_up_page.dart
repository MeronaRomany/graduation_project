import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// تأكد من صحة مسار ملف الـ Firestore في مشروعك
import '../../services/firestore_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();

  bool isNotVisible = true;
  late UsersFireStore usersFireStore = UsersFireStore();

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
                clipBehavior: Clip.none, // مهم لظهور النص المرفوع
                children: [
                  CustomPaint(
                    painter: LoginBorderPainter(),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: width * 0.9,
                      height: 650,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Let's Create Account Together",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff666666),
                                  ),
                                ),
                              ],
                            ),

                            TextFormField(
                              controller: username,
                              validator: (value) => value!.isEmpty
                                  ? "please, Enter your Full name"
                                  : null,
                              decoration: buildInputDecoration('Full name'),
                            ),

                            TextFormField(
                              controller: email,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Please, enter your email";
                                String pattern =
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                                if (!RegExp(pattern).hasMatch(value))
                                  return "Please, enter a valid email";
                                return null;
                              },
                              decoration: buildInputDecoration('Email'),
                            ),

                            TextFormField(
                              controller: password,
                              obscureText: isNotVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "please, Enter your password";
                                if (value.length < 6)
                                  return "password at least 6 char";
                                return null;
                              },
                              decoration:
                                  buildInputDecoration('Password').copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isNotVisible = !isNotVisible;
                                    });
                                  },
                                  icon: Icon(isNotVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () async {
                                if (formkey.currentState!.validate()) {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                  )
                                      .then((data) async {
                                    String uid = data.user!.uid;
                                    await usersFireStore.createUserToFireStore(
                                      uid,
                                      username.text,
                                      email.text,
                                    );
                                    _showMyDialog("SignUp successful",
                                        "Welcome ${data.user!.email}", true);
                                  }).catchError((error) {
                                    _showMyDialog(
                                        "SignUp unsuccessful",
                                        error.message ?? error.toString(),
                                        false);
                                  });
                                }
                              },
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xff4A90E2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff666666))),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, "signIn"),
                                  child: const Text('Sign in',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                          color: Color(0xff666666))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.transparent,
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                          fontSize: width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
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

  // دالة مساعدة للديزاين بتاع الـ Input
  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff4A90E2)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff4A90E2), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff4A90E2), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  // دالة لإظهار الرسائل (Dialog)
  void _showMyDialog(String title, String content, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess)
                Navigator.pushReplacementNamed(context, "homePage");
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class LoginBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    double radius = 20;

    // ضبط الفتحة لتناسب كلمة SIGN UP
    double gapWidth = size.width * 0.42;
    double startGap = (size.width - gapWidth) / 2;
    double endGap = startGap + gapWidth;

    path.moveTo(endGap, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(startGap, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
