import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // The app starts on the splash screen. These callbacks also handle
      // deep links like humavolve://huma-volve.com/product/5 (see AppRouter).
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
