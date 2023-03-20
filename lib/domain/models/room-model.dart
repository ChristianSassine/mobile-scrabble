import 'dart:core';

// TODO: To be adapted to the server room implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Room {
  final String id;
  final List<String> users;
  final String dictionary;
  final int timer;
  final RoomType mode;

  Room(this.id, this.users, this.dictionary, this.timer, this.mode);

  Room.fromJson(json)
      : id = json['id'],
        users = json['users'],
        dictionary = json['dictionary'],
        timer = json['timer'],
        mode = json['mode'];

  Map toJson() =>
      {
        "id": id,
        "users": users,
        "dictionary": dictionary,
        "timer" : timer,
        "mode" : mode
      };
}

enum RoomType {
  PUBLIC("public"),
  PRIVATE("private");

  const RoomType(this.value);

  final String value;
}
