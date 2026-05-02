import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/shared_prefs.dart';
import 'api_client.dart';

class AuthApi {
  AuthApi._();

  /// Login with email + password. Saves token + user info locally.
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.post(AppConstants.login, {
      'email': email,
      'password': password,
    }, auth: false);
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _persistSession(response);
    return response;
  }

  /// Register step 1: email, phone, password
  static Future<AuthResponse> register({
    required String email,
    required String phoneNo,
    required String password,
  }) async {
    final data = await ApiClient.post(AppConstants.register, {
      'email': email,
      'phone_no': phoneNo,
      'password': password,
    }, auth: false);
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _persistSession(response);
    return response;
  }

  /// Profile setup step 2: name + address (+ optional photo handled separately)
  static Future<UserModel> profileSetup({
    required String name,
    required String address,
  }) async {
    final data = await ApiClient.put(AppConstants.profileSetup, {
      'name': name,
      'address': address,
    });
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await SharedPrefs.saveUserName(user.name);
    if (user.profilePic != null)
      await SharedPrefs.saveUserPhoto(user.profilePic);
    return user;
  }

  /// Persist token + basic user data locally after auth
  static Future<void> _persistSession(AuthResponse response) async {
    await SharedPrefs.saveToken(response.token);
    await SharedPrefs.saveUserId(response.user.userId);
    await SharedPrefs.saveUserName(response.user.name);
    await SharedPrefs.saveUserEmail(response.user.email);
    if (response.user.profilePic != null) {
      await SharedPrefs.saveUserPhoto(response.user.profilePic);
    }
    await SharedPrefs.setLoggedIn(true);
  }

  static Future<void> logout() async {
    await SharedPrefs.clearAll();
    final token = await SharedPrefs.getToken();
    print('TOKEN AFTER LOGOUT: $token');
  }
}
