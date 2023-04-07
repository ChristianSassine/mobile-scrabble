import 'package:flutter/material.dart';
import 'package:mobile/domain/models/user-image-info-model.dart';

class IUser {
  final String username;
  final String? id;
  final String? email;
  final String? password;
  final UserImageInfo? profilePicture;

  IUser(
      {required this.username,
        this.password,
        this.email,
        this.id,
        this.profilePicture});

  IUser.fromJson(json)
      : username = json['username'],
        id = json['_id'],
        email = json['email'],
        password = json['password'],
        profilePicture = json['profilePicture'] != null
            ? UserImageInfo.fromJson(json['profilePicture'])
            : null;

  Map toJson() => {
        "email": email,
        "username": username,
        "password": password,
        "profilePicture": profilePicture,
        "_id": id
      };
}
