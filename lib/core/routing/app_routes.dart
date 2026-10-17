/// Route names of the screens that can be opened by name (and by deep link).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';

  /// First path segment of the product details route.
  static const String productSegment = 'product';

  /// `/product/{id}`, e.g. `/product/5`.
  static String productDetails(int productId) => '/$productSegment/$productId';

  /// Reads the product id from a route.
  ///
  /// Accepts the route name (`/product/5`, what Flutter pushes when a link
  /// arrives while the app is running) and the full link
  /// (`humavolve://huma-volve.com/product/5`, the first route when the link
  /// starts the app). Returns null for any other route or an invalid id.
  static int? productIdFrom(String? route) {
    if (route == null || route.isEmpty) return null;
    final uri = Uri.tryParse(route);
    if (uri == null) return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments.first != productSegment) return null;

    final productId = int.tryParse(segments[1]);
    return productId != null && productId > 0 ? productId : null;
  }
}

/// Links that open the app from outside (a browser, WhatsApp, notes, adb).
///
/// The scheme and host must match the `<intent-filter>` in
/// `android/app/src/main/AndroidManifest.xml`.
class DeepLinks {
  DeepLinks._();

  static const String scheme = 'humavolve';
  static const String host = 'huma-volve.com';

  /// `humavolve://huma-volve.com/product/{id}`
  static Uri product(int productId) => Uri(
    scheme: scheme,
    host: host,
    path: AppRoutes.productDetails(productId),
  );
}
