import 'dart:core';

// TODO: To be adapted to the server room implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Room {
  final String name;
  final RoomType type;
  List<String> playerList;

  Room(this.name, this.type, this.playerList);

  Room.fromJson(json)
      : name = json['name'],
        type = json['type'],
        playerList = json['memberList'];

  Map toJson() =>
      {"name": name,
        "type": type,
        "memberList": playerList};
}

enum RoomType {
  PUBLIC("public"),
  PRIVATE("private");

  const RoomType(this.value);

  final String value;
}

class IUser {
  final String? email, profilePicture;
  final String username, password;

  IUser({required this.username, required this.password, this.email, this.profilePicture});


  IUser.fromJson(json)
      : email = json['email'],
        username = json['username'],
        password = json ['password'],
        profilePicture = json['profilePicture'];

  Map toJson() =>
      {"email": email,
        "username": username,
        "password": password,
        "profilePicture": profilePicture};
}
