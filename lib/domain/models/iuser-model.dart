import 'package:mobile/domain/models/userimageinfo-model.dart';

class IUser {
  final String? email;
  final String username, password;
  final UserImageInfo? profilePicture;

  IUser(
      {required this.username,
        required this.password,
        this.email,
        this.profilePicture});

  IUser.fromJson(json)
      : email = json['email'],
        username = json['username'],
        password = json['password'],
        profilePicture = json['profilePicture'] != null
            ? UserImageInfo.fromJson(json['profilePicture'])
            : null;

  Map toJson() => {
    "email": email,
    "username": username,
    "password": password,
    "profilePicture": profilePicture
  };
}
