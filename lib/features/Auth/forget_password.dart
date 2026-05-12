import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatelessWidget {
   ForgetPasswordPage({super.key});
  final formkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none, // لضمان ظهور النص المرفوع فوق الحدود
              children: [
                /// البوردر المرسوم مع الفتحة العلوية
                CustomPaint(
                  painter: LoginBorderPainter(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: width * 0.9,
                    height: 450,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          const Text(
                            'Recovery Password',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Please Enter Your Email Address To Receive a Verification Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff666666),
                            ),
                          ),

                          TextFormField(
                            controller: email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please, enter your email";
                              }return null;
                            },
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4A90E2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xff4A90E2),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xff4A90E2),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              if (formkey.currentState!.validate()) {
                                FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email.text.trim())
                                    .then((_) {
                                  _showDialog(context, "Email Sent", "Check your inbox for a password reset link.");
                                }).catchError((error) {
                                  _showDialog(context, "Error", error.message ?? "Something went wrong.");
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
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: -18, // رفعه ليتقاطع مع الخط العلوي
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.transparent,
                    child: Text(
                      "Forget Password",
                      style: TextStyle(
                        fontSize: width * 0.065, // تكبير الخط ليناسب التصميم
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    double radius = 20;

    // توسيع الفتحة لتناسب جملة Forget Password العريضة
    double gapWidth = size.width * 0.62;
    double startGap = (size.width - gapWidth) / 2;
    double endGap = startGap + gapWidth;

    // الجزء العلوي الأيمن
    path.moveTo(endGap, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // الضلع الأيمن
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // الضلع السفلي
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // الضلع الأيسر
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // الجزء العلوي الأيسر وصولاً لبداية الكلمة
    path.lineTo(startGap, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}