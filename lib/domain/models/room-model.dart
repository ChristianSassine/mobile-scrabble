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
        users = (json['users'] as List<dynamic>).map((e) => e as String).toList() as List<String>,
        dictionary = json['dictionary'],
        timer = json['timer'],
        mode = RoomType.toEnum(json['mode']);

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

  static RoomType toEnum(String value){
    RoomType? room = RoomType.values.asMap()[value];
    if (room == null) return RoomType.PUBLIC;
    return room;
  }

  final String value;
}
