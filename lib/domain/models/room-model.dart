import 'dart:core';

import 'package:mobile/domain/models/player-models.dart';

// TODO: To be adapted to the server room implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Room {
  final String name;
  final RoomType type;
  List<Player> playerList;

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
