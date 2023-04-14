class DragInfos {
  String roomId;
  String socketId;
  String letter;
  List<int> coord;
  List<int> window;

  DragInfos.fromJson(data)
      : roomId = data['roomId'],
        socketId = data['socketId'],
        letter = data['letter'],
        coord = data['coord'],
        window = data['window'];

  Map toJson() =>
      {"roomId": roomId, "socketId": socketId, "letter": letter, "coord": coord, "window": window};
}

class SimpleLetterInfos {
  String roomId;
  String socketId;
  String letter;
  int coord;

  SimpleLetterInfos(this.roomId, this.socketId, this.letter, this.coord);

  SimpleLetterInfos.fromJson(data)
      : roomId = data['roomId'],
        socketId = data['socketId'],
        letter = data['letter'],
        coord = data['coord'];

  Map toJson() => {"roomId": roomId, "socketId": socketId, "letter": letter, "coord": coord};
}
