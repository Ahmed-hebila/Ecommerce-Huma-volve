import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../main_navigation/screens/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.deepLinkProductId});

  /// Set when the app was opened from a product link
  /// (humavolve://huma-volve.com/product/{id}). The product details screen
  /// is opened on top of the first screen after the splash.
  final int? deepLinkProductId;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Check the saved session while the splash is showing.
    final isLoggedInFuture = Injection.checkAuthStatusUseCase();
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = (await isLoggedInFuture).fold(
      (failure) => false,
      (loggedIn) => loggedIn,
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => isLoggedIn
            ? const MainNavigationScreen()
            : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // Opened from a deep link: show the product on top, so the back button
    // goes to the home (or login) screen.
    final productId = widget.deepLinkProductId;
    if (productId != null) {
      navigator.pushNamed(AppRoutes.productDetails(productId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 120,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Huma-volve',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Ultimate E-Commerce App',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
