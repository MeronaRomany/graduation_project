import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    TextEditingController email = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: formkey,
            child: Column(
              spacing: 20,
              children: [
                Text(
                  'Recovery Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Please Enter Your Email Address To Receive a Verification Code',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.grey),
                ),

                TextFormField(
                  controller: email,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please, Enter your Full name";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 20),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
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
                    if (formkey.currentState!.validate()) {
                      FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email.text.trim())
                          .then((_) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text("Reset password email sent"),
                            content: Text(
                              "Check your inbox for a password reset link.",
                            ),
                          ),
                        );
                      }).catchError((error) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Reset failed"),
                            content: Text(error.message ?? "Something went wrong."),
                          ),
                        );
                      });
                    }
                  },
                  child: Container(
                    height: 65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 25,
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
    );
  }
}
