import 'package:mobile/domain/models/userimageinfo-model.dart';

class IUser {
  String username;
  UserImageInfo? profilePicture;

  IUser(this.username, {this.profilePicture});

  IUser.fromJson(json)
      : profilePicture = UserImageInfo.fromJson(json['profilePicture']),
        username = json['username'];

  Map toJson() => {
        "username": username,
        "profilePicture": profilePicture,
      };
}
