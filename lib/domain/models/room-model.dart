import 'package:rxdart/rxdart.dart';

class Room {
  final String name;
  final RoomType type;

  Room(this.name, this.type);

  Room.fromJson(json)
      : name = json['name'],
        type = json['type'];

  Map toJson() => {"name": name, "type": type};
}

enum RoomType {
  PUBLIC("public"),
  PRIVATE("private");

  const RoomType(this.value);

  final String value;
}
