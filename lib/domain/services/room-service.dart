import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/server-events-enum.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/game-screen.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

class RoomService {
  // FOR TESTING
  final Socket _socket = GetIt.I.get<Socket>();
  final UserService _userService = GetIt.I.get<UserService>();

  List<GameRoom> roomList = [];
  GameRoom? currentRoom;
  Subject<List<GameRoom>> notifyNewRoomList = PublishSubject();
  Subject<GameRoom?> notifyRoomMemberList = PublishSubject();
  Subject<GameRoom?> notifyRoomJoin = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  RoomService() {
    initSocketListeners();
  }

  void connectToRooms() {
    _socket.emit(RoomSocketEvent.EnterRoomLobby.event);
  }

  void initSocketListeners() {
    _socket.on(RoomSocketEvent.UpdateGameRooms.event, (data) {
      final newRooms =
          (data as List<dynamic>).map((e) => GameRoom.fromJson(e)).toList();
      _updateRoomList(newRooms);
    });

    _socket.on(RoomSocketEvent.JoinedValidWaitingRoom.event, (data) {
      final gameRoom = GameRoom.fromJson(data);
      debugPrint("Join GameRoom request accepted");
      _joinRoom(gameRoom);
    });

    _socket.on(RoomSocketEvent.UpdateWaitingRoom.event, (data) {
      currentRoom = GameRoom.fromJson(data);
      notifyRoomMemberList.add(currentRoom);
    });

    _socket.on(RoomSocketEvent.GameAboutToStart.event, (data) {
      if (data == null) return;
      GameService gameService = GetIt.I.get<GameService>();
      gameService.startGame(GameInfo.fromJson(data));
      Navigator.pushReplacement(
          GetIt.I.get<GlobalKey<NavigatorState>>().currentContext!,
          MaterialPageRoute(builder: (context) => const GameScreen()));
    });

    _socket.on(
        RoomSocketEvent.ErrorJoining.event,
        (errorMsg) => notifyError
            .add(parseServerError(ServerEvents.fromString(errorMsg))));

    _socket.on(RoomSocketEvent.KickedFromWaitingRoom.event, (_) {
      currentRoom = null;
      Navigator.pop(GetIt.I.get<GlobalKey<NavigatorState>>().currentContext!);
    });
  }

  String parseServerError(ServerEvents error) {
    switch (error) {
      case ServerEvents.RoomNotAvailable:
        return "rooms_lobby.errors.not_available";
      case ServerEvents.RoomWrongPassword:
        return "rooms_lobby.errors.wrong_password";
      case ServerEvents.RoomSameUser:
        return "rooms_lobby.errors.same_user";
      default:
        return "ERROR";
    }
  }

  void _updateRoomList(List<GameRoom> newRooms) {
    roomList = newRooms;
    notifyNewRoomList.add(newRooms);
  }

  void requestJoinRoom(String roomId, [String? password]) {
    final player = RoomPlayer(_userService.user!, roomId, password: password);
    _socket.emit(RoomSocketEvent.JoinWaitingRoom.event, player);
  }

  void _joinRoom(GameRoom newRoom) {
    currentRoom = newRoom;
    notifyRoomJoin.add(currentRoom!);
    debugPrint("GameRoom Joined");
  }

  void createRoom(GameCreationQuery creationQuery) {
    _socket.emit(RoomSocketEvent.CreateWaitingRoom.event, creationQuery);

    // Temporary until UpdateWaitingRoom is called
    currentRoom = GameRoom(
        id: "-",
        players: [
          RoomPlayer(creationQuery.user, "-",
              playerType: PlayerType.User, isCreator: true)
        ],
        dictionary: creationQuery.dictionary,
        timer: creationQuery.timer,
        gameMode: creationQuery.gameMode,
        visibility: creationQuery.visibility);
  }

  void exitRoom() {
    if (currentRoom == null) return;
    UserRoomQuery exitQuery =
        UserRoomQuery(user: _userService.user!, roomId: currentRoom!.id);
    _socket.emit(RoomSocketEvent.ExitWaitingRoom.event, exitQuery);
  }

  void startScrabbleGame() {
    GetIt.I.get<GameService>(); // Init Game Service
    _socket.emit(RoomSocketEvent.StartScrabbleGame.event, currentRoom!.id);
  }

  void kickPlayerFromWaitingRoom(RoomPlayer player) {
    UserRoomQuery exitQuery =
        UserRoomQuery(user: player.user, roomId: currentRoom!.id);
    _socket.emit(RoomSocketEvent.ExitWaitingRoom.event, exitQuery);
  }
}
