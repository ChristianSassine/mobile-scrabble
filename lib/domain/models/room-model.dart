import 'dart:core';

import 'package:flutter/cupertino.dart';

// TODO: To be adapted to the server room implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Room {
  final String name;
  final GameVisibility type;
  List<String> playerList;

  Room(this.name, this.type, this.playerList);

  Room.fromJson(json)
      : name = json['name'],
        type = json['type'],
        playerList = json['memberList'];

  Map toJson() => {"name": name, "type": type, "memberList": playerList};
}

class ImageInfo {
  final String name;
  final bool isDefaultPicture;
  final String? key;

  ImageInfo.fromJson(json)
      : name = json['name'],
        isDefaultPicture = json['isDefaultPicture'],
        key = json['key'];
}

class IUser {
  final String? email;
  final String username, password;
  final ImageInfo? profilePicture;

  IUser({required this.username, required this.password, this.email, this.profilePicture});

  IUser.fromJson(json)
      : email = json['email'],
        username = json['username'],
        password = json['password'],
        profilePicture = json['profilePicture'] != null ? ImageInfo.fromJson(json['profilePicture']) : null;

  Map toJson() => {
        "email": email,
        "username": username,
        "password": password,
        "profilePicture": profilePicture
      };
}

enum GameMode {
  Null(""),
  Solo("solo"),
  Multi("multi");

  const GameMode(this.value);

  final String value;

  static GameMode? fromString(String sValue) {
    for (GameMode mode in values) {
      if (mode.value == sValue) {
        return mode;
      }
    }
    return null;
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
  final String socketId;
  final String roomId;
  final PlayerType? playerType;
  final bool? isCreater;

  RoomPlayer(this.user, this.socketId, this.roomId, this.playerType, this.isCreater);

  RoomPlayer.fromJson(json)
      : user = IUser.fromJson(json['user']),
        socketId = json['socketId'],
        roomId = json['roomId'],
        playerType = PlayerType.fromString(json['type']),
        isCreater = json['isCreator'];
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
        gameMode = GameMode.fromString(json['mode'])!,
        visibility = GameVisibility.fromString(json['visibility'])!,
        password = json['password'];
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
