import 'dart:convert';

import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/models/user-image-info-model.dart';

class SettingsInfo {
  final String language;
  final ThemeInfo themeInfo;

  SettingsInfo.fromJson(json)
      : language = json['language'],
        themeInfo = ThemeInfo.fromJson(jsonDecode(json['theme']));
}

class ThemeInfo {
  final MobileTheme mainTheme;
  final MobileTheme lightTheme;
  final MobileTheme darkTheme;
  final bool isDynamic;

  ThemeInfo.fromJson(json)
      : mainTheme = MobileTheme.fromString(json['mainTheme']),
        lightTheme = MobileTheme.fromString(json['lightTheme']),
        darkTheme = MobileTheme.fromString(json['darkTheme']),
        isDynamic = json['isDynamic']
  ;
}

class IUser {
  final String? email;
  final String username;
  final String? password;
  final UserImageInfo? profilePicture;

  IUser(
      {required this.username, this.password, this.email, this.profilePicture});

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
