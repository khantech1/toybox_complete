class AppConstants {
  AppConstants._();
  static const String serverUrl = 'http://192.168.43.208:55595';
  static const String baseUrl = '$serverUrl/api';

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://localhost:5000')) {
      return path.replaceFirst('http://localhost:5000', serverUrl);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$serverUrl$path';
    }

    return '$serverUrl/$path';
  }
  //─────────────────────────────────────────────────────────────────────────

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profileSetup = '/auth/profile-setup';

  // Toys endpoints
  static const String toys = '/toys';
  static const String myToys = '/toys/my-toys';

  // Categories endpoint
  static const String categories = '/categories';

  // Exchange requests endpoints
  static const String exchangeRequests = '/exchange-requests';

  // Reviews endpoint
  static const String reviews = '/reviews';

  // Profile endpoint
  static const String profile = '/profile';
  static const String contacts = '/contacts';
  static const String syncContacts = '/contacts/sync';

  // Shared prefs keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userPhotoKey = 'user_photo';
  static const String isLoggedInKey = 'is_logged_in';
}
