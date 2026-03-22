import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/features/Auth/forget_password.dart';
import 'package:graduation_app/features/Auth/sign_up_page.dart';
import 'package:graduation_app/features/home/presentation/view/home_view.dart';
import 'package:graduation_app/features/home/presentation/view/main_view.dart';

import 'google_sign_in.dart';

class SignInPage extends StatefulWidget {
  static const String routeName = "signIn";
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: formkey,
            child: Column(
              spacing: 30,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Hello Again!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'welcome Back You\'ve Been Missed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                TextFormField(
                  controller: email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please, enter your email";
                    }

                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                    RegExp regex = RegExp(pattern);

                    if (!regex.hasMatch(value)) {
                      return "Please, enter a valid email";
                    }

                    return null;
                  },
                  style: TextStyle(fontSize: 18),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Color(0xff4A249D),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff4A249D), width: 2.0),
                      )),
                ),
                // SizedBox(height: 10,),

                TextFormField(
                  controller: password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please, Enter your password";
                    }
                    if (value.length < 6) {
                      return "please, should be at least 6 char";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 20),
                  textInputAction: TextInputAction.search,
                  obscureText: isNotVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        changePasswordVisible(!isNotVisible);
                        setState(() {});
                      },
                      icon: Icon(
                        isNotVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xff4A249D),
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff4A249D),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ForgetPasswordPage.routeName);
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Recovery password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

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
                            content: Text("Welcome ${data.user!.email}"),
                          ),
                        );

                        Navigator.pushReplacementNamed(
                            context, MainView.routeName);
                      }).catchError((error) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text("Login unsuccessful"),
                            content:
                                Text("Please check your email or password."),
                          ),
                        );
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Spacer(),
                Text(
                  "Or SignIn",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                ElevatedButton.icon(
                    onPressed: () async {
                      await AuthWithGoogle.signInWithGoogle(context);
                    },
                    label: Text("Sign in with Google",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: 30,
                      color: Colors.deepPurple,
                    )),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignUpPage.routeName);
                        },
                        child: Text(
                          'Sign up for free',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
