import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/routing/app_router.dart';
import 'package:ecommerce_app_huma_volve/core/routing/app_routes.dart';
import 'package:ecommerce_app_huma_volve/core/routing/not_found_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter', () {
    test('builds the product details route for /product/{id}', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/product/5'),
      );

      expect(route, isA<MaterialPageRoute<void>>());
      expect(route?.settings.name, '/product/5');
    });

    test('returns null for other routes so onUnknownRoute handles them', () {
      expect(
        AppRouter.onGenerateRoute(const RouteSettings(name: '/cart')),
        isNull,
      );
    });

    test('a deep link still starts the app on the splash screen', () {
      final routes = AppRouter.onGenerateInitialRoutes(
        DeepLinks.product(5).toString(),
      );

      expect(routes, hasLength(1));
      expect(routes.single.settings.name, AppRoutes.splash);
    });
  });

  testWidgets('an unknown link shows the not found screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/does-not-exist',
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        onGenerateInitialRoutes: (initialRoute) => [
          AppRouter.onUnknownRoute(RouteSettings(name: initialRoute)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(NotFoundScreen.title), findsOneWidget);
  });
}
