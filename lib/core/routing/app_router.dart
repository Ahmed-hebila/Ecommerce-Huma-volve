import 'package:flutter/material.dart';

import '../../features/details/presentation/screens/product_details_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';

/// Builds the screens for the routes that come from deep links.
///
/// - Cold start (the link opens the app): Flutter gives the link to
///   [onGenerateInitialRoutes]. The app still starts on the splash screen
///   (to check the session), and the splash opens the product after it.
/// - Warm start (the app is already open): Flutter pushes `/product/{id}`,
///   [onGenerateRoute] builds the product details screen on top of the
///   current screen.
class AppRouter {
  AppRouter._();

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    return [
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.splash),
        builder: (_) => SplashScreen(
          deepLinkProductId: AppRoutes.productIdFrom(initialRoute),
        ),
      ),
    ];
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final productId = AppRoutes.productIdFrom(settings.name);
    if (productId != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ProductDetailsScreen(productId: productId),
      );
    }
    // Any other route goes to [onUnknownRoute].
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const NotFoundScreen(),
    );
  }
}
