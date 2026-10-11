import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme.dart';
import '../../../main_navigation/screens/main_navigation_screen.dart';
import '../../data/auth_service.dart';
import '../../sign_up/screens/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.shopping_bag, size: 80, color: AppTheme.primary),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displayLarge
                      ?.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue your shopping',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) => const SignUpScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
