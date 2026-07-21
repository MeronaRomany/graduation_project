import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/features/Auth/sign_up_page.dart';

import 'package:graduation_app/core/theme/colors_manager.dart';
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

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeSlide = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeView.routeName);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mapFirebaseError(e.code)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Invalid email or password';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsManager.primary,
              ColorsManager.primary.withValues(alpha: 0.85),
              ColorsManager.primary.withValues(alpha: 0.7),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeSlide,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorsManager.primary,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsManager.primary.withValues(alpha: 0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 56,
                        color: ColorsManager.primary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.028),
                    Text(
                      'Welcome Back',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.006),
                    Text(
                      'Sign in to continue',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: size.height * 0.035),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: colorScheme.surface,
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(v)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  labelStyle: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.016),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _signIn(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  labelStyle: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.006),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    ForgetPasswordPage.routeName,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorsManager.primary,
                                    disabledBackgroundColor:
                                        ColorsManager.primary
                                            .withValues(alpha: 0.4),
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor:
                                        Colors.white.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style:
                                              textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.025),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Or continue with',
                                      style:
                                          textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await AuthWithGoogle.signInWithGoogle(
                                        context);
                                    if (!context.mounted) return;
                                    if (FirebaseAuth
                                            .instance.currentUser !=
                                        null) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        MainView.routeName,
                                      );
                                    }
                                  },
                                  icon: Image.asset(
                                    'assets/images/search.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                  label: Text(
                                    'Sign in with Google',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            SignUpPage.routeName,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
