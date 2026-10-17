/// Base URL and endpoints of the Platzi Fake Store API.
/// Docs: https://api.escuelajs.co/docs
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.escuelajs.co/api/v1/';

  // Auth
  static const String login = 'auth/login';
  static const String profile = 'auth/profile';
  static const String refreshToken = 'auth/refresh-token';

  // Users
  static const String users = 'users/';
  static const String isEmailAvailable = 'users/is-available';

  // Home
  static const String categories = 'categories';
  static const String products = 'products';

  /// `categories/{id}/products`
  static String categoryProducts(int categoryId) =>
      '$categories/$categoryId/$products';

  /// `products/{id}`
  static String productDetails(int productId) => '$products/$productId';

  // Pagination query parameters: `?offset=0&limit=10`
  static const String offsetParam = 'offset';
  static const String limitParam = 'limit';

  /// The API requires an avatar URL when creating a user.
  static const String defaultAvatar = 'https://i.imgur.com/LDOO4Qs.jpg';
}
