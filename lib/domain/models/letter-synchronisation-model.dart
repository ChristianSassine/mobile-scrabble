import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';

class DragInfos {
  String roomId;
  String socketId;
  String letter;
  late List<int> coord;
  late List<int> window;

  DragInfos(this.roomId, this.socketId, this.letter, this.coord, this.window);

  DragInfos.fromJson(data)
      : roomId = data['roomId'],
        socketId = data['socketId'],
        letter = data['letter'],
        coord = data['coord'].map<int>((element) => element as int).toList(),
        window = data['window'].map<int>((element) => element as int).toList();

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

class OpponentDraggedLetter {
  Coordinate coord;
  Letter letter;

  OpponentDraggedLetter(this.coord, this.letter);
}
