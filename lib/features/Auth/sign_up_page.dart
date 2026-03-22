import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Let's Create Account Together",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                  controller: username,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please, Enter your Full name";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 20),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null && !user.emailVerified) {
                          await user.sendEmailVerification();

                          print("✅ Verification Email Sent");
                        }

                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                            title: const Text("SignUp successful"),
                            content: Text(
                              "Welcome  ${data.user!.email}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    "homePage",
                                  );
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      })
                          .catchError((error) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                            title: const Text("SignUp unsuccessful"),
                            content: Text(
                              error.message ?? error.toString(),
                            ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        "homePage",
                                      );
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
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

                    child: Center(
                      child: Text(
                        'Sign Up',
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "signIn");
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,
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
