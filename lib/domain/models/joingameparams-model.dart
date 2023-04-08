import 'package:mobile/domain/models/user-auth-models.dart';

class JoinGameParams {
  String roomId;
  IUser player;
  String? password;

  JoinGameParams(this.roomId, this.player, {this.password});

  JoinGameParams.fromJson(json)
      : roomId = json['roomId'],
        player = IUser.fromJson(json['player']),
        password = json['password'];

  Map toJson() =>
      {
        "roomId": roomId,
        "player": player,
        "password": password,
      };
}
