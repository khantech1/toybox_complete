import 'user_model.dart';

class ContactModel {
  final int userId;
  final int contactId;
  final UserModel? contactUser;

  const ContactModel({
    required this.userId,
    required this.contactId,
    this.contactUser,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      userId: json['user_id'] as int,
      contactId: json['contact_id'] as int,
      contactUser: json['contact_user'] != null
          ? UserModel.fromJson(json['contact_user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'contact_id': contactId,
      };
}
