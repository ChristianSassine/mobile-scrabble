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

class IUser {
  final String? email, profilePicture;
  final String username, password;

  IUser({required this.username, required this.password, this.email, this.profilePicture});

  IUser.fromJson(json)
      : email = json['email'],
        username = json['username'],
        password = json['password'],
        profilePicture = json['profilePicture'];

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
}

enum GameVisibility {
  Public("public"),
  Locked("locked"),
  Private("private");

  const GameVisibility(this.value);

  final String value;
}

enum GameDifficulty {
  Easy("difficulty.beginner"),
  Hard("difficulty.expert"),
  ScoreBased("difficulty.score-based");

  const GameDifficulty(this.value);

  final String value;
}

enum PlayerType {
  User("user"),
  Bot("bot"),
  Observer("observer");

  const PlayerType(this.value);

  final String value;
}

class RoomPlayer {
  final IUser user;
  final String socketId;
  final String roomId;
  final PlayerType? playerType;
  final bool? isCreater;

  RoomPlayer(this.user, this.socketId, this.roomId, this.playerType, this.isCreater);
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
      : this.id = json['id'],
        this.players = json['players'],
        this.dictionary = json['disctionary'],
        this.timer = json['timer'],
        this.gameMode = json['mode'],
        this.visibility = json['visibility'],
        this.password = json['password'] {}
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
