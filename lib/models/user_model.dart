class UserModel {
  final int userId;
  final String name;
  final String email;
  final String? phoneNo;
  final String? address;
  final String? profilePic;
  final double? rating;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNo,
    this.address,
    this.profilePic,
    this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'no email',
      phoneNo: json['phone_no'] as String?,
      address: json['address'] as String?,
      profilePic: json['profile_pic'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_no': phoneNo,
      'address': address,
      'profile_pic': profilePic,
      'rating': rating,
    };
  }

  UserModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phoneNo,
    String? address,
    String? profilePic,
    double? rating,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      address: address ?? this.address,
      profilePic: profilePic ?? this.profilePic,
      rating: rating ?? this.rating,
    );
  }
}

class AuthResponse {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
