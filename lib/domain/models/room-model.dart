import 'dart:core';

import 'package:mobile/domain/models/user-auth-models.dart';

enum GameMode {
  Null(""),
  Solo("solo"),
  Multi("multi");

  const GameMode(this.value);

  final String value;

  static GameMode fromString(String sValue) {
    for (GameMode mode in values) {
      if (mode.value == sValue) {
        return mode;
      }
    }
    return GameMode.Null;
  }
}

enum GameVisibility {
  Public("public"),
  Locked("locked"),
  Private("private");

  const GameVisibility(this.value);

  final String value;

  static GameVisibility? fromString(String sValue) {
    for (GameVisibility visibility in values) {
      if (visibility.value == sValue) {
        return visibility;
      }
    }
    return null;
  }
}

enum GameDifficulty {
  Easy("difficulty.beginner"),
  Hard("difficulty.expert"),
  ScoreBased("difficulty.score-based");

  const GameDifficulty(this.value);

  final String value;

  static GameDifficulty? fromString(String sValue) {
    for (GameDifficulty difficulty in values) {
      if (difficulty.value == sValue) {
        return difficulty;
      }
    }
    return null;
  }
}

enum PlayerType {
  User("user"),
  Bot("bot"),
  Observer("observer");

  const PlayerType(this.value);

  final String value;

  static PlayerType? fromString(String sValue) {
    for (PlayerType playerType in values) {
      if (playerType.value == sValue) {
        return playerType;
      }
    }
    return null;
  }
}

class RoomPlayer {
  final IUser user;
  final String roomId;
  final String? password;
  final PlayerType? playerType;
  final bool? isCreator;

  RoomPlayer(this.user, this.roomId, { this.playerType, this.isCreator, this.password});

  RoomPlayer.fromJson(json)
      : user = IUser.fromJson(json['user']),
        roomId = json['roomId'],
        password = json['password'],
        playerType = PlayerType.fromString(json['type']),
        isCreator = json['isCreator'];

  Map toJson() => {
    "user": user.toJson(),
    "roomId": roomId,
    "password": password,
    "playerType": playerType?.value,
    "isCreator": isCreator,
  };
}

class GameRoom {
  final String id;
  final List<RoomPlayer> players;
  final String dictionary;
  final int timer;
  final GameMode gameMode;
  final GameVisibility visibility;
  final String? password;

  GameRoom(
      {required this.id,
      required this.players,
      required this.dictionary,
      required this.timer,
      required this.gameMode,
      required this.visibility,
      this.password});

  GameRoom.fromJson(json)
      : id = json['id'],
        players = json['players'].map<RoomPlayer>(RoomPlayer.fromJson).toList(),
        dictionary = json['dictionary'],
        timer = json['timer'],
        gameMode = GameMode.fromString(json['mode']),
        visibility = GameVisibility.fromString(json['visibility'])!,
        password = json['password'];

  bool containsTwoPlayers () => players.where((element) => element.playerType != PlayerType.Bot).length >= 2;
  bool isPlayerCreator(IUser player) => players.firstWhere((element) => element.isCreator == true).user.id == player.id;
}

class GameCreationQuery {
  final IUser user;
  final String dictionary;
  final int timer;
  final GameMode gameMode;
  final GameVisibility visibility;
  final String? password;
  final GameDifficulty botDifficulty;

  GameCreationQuery(
      {required this.user,
      required this.dictionary,
      required this.timer,
      required this.gameMode,
      required this.visibility,
      this.password,
      required this.botDifficulty});

  Map toJson() => {
        "user": user.toJson(),
        "dictionary": dictionary,
        "timer": timer,
        "mode": gameMode.value,
        "visibility": visibility.value,
        "password": password,
        "botDifficulty": botDifficulty.value
      };
}

class UserRoomQuery {
  final String roomId;
  final IUser user;
  final String? password;

  UserRoomQuery({required this.user, required this.roomId, this.password});

  Map toJson() => {"roomId": roomId, "user": user};
}
