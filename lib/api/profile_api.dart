import 'dart:io';
import '../models/user_model.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';
import '../utils/shared_prefs.dart';
import 'api_client.dart';

class ProfileApi {
  ProfileApi._();

  /// Get current user profile
  static Future<UserModel> getMe() async {
    final data = await ApiClient.get(AppConstants.profile);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Get any user profile by ID
  static Future<UserModel> getById(int userId) async {
    final data = await ApiClient.get('${AppConstants.profile}/$userId');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Update current user profile (name, address)
  static Future<UserModel> update({String? name, String? address}) async {
    final data = await ApiClient.put(AppConstants.profile, {
      'name': ?name,
      'address': ?address,
    });
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await SharedPrefs.saveUserName(user.name);
    return user;
  }

  /// Upload/change profile picture
  static Future<UserModel> uploadProfilePic(File image) async {
    final data = await ApiClient.uploadFile(
      '${AppConstants.profile}/photo',
      'profile_pic',
      image,
      {},
    );
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    if (user.profilePic != null) {
      await SharedPrefs.saveUserPhoto(user.profilePic);
    }
    return user;
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  static Future<List<ContactModel>> getContacts() async {
    final data = await ApiClient.get(AppConstants.contacts);
    return (data as List)
        .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addContact(int contactUserId) async {
    await ApiClient.post(AppConstants.contacts, {'contact_id': contactUserId});
  }

  static Future<void> removeContact(int contactUserId) async {
    await ApiClient.delete('${AppConstants.contacts}/$contactUserId');
  }

  static Future<List<ContactModel>> syncContacts(
    List<String> phoneNumbers,
  ) async {
    final data = await ApiClient.post(AppConstants.syncContacts, {
      'phoneNumbers': phoneNumbers,
    });

    return (data as List)
        .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
