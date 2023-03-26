import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  final Socket _socket = GetIt.I.get<Socket>();
  final AuthService _authService = GetIt.I.get<AuthService>();

  List<GameRoom> roomList = [];
  GameRoom? currentRoom;
  Subject<List<GameRoom>> notifyNewRoomList = PublishSubject();
  Subject<GameRoom> notifyRoomMemberList = PublishSubject();

  RoomService() {
    initSocketListeners();
  }

  void initSocketListeners() {
    _socket.on(RoomSocketEvent.UpdateWaitingRoom.event, (data) {
      currentRoom = GameRoom.fromJson(data);
      notifyRoomMemberList.add(currentRoom!);
    });
  }

  void updateRoomList() {
    // TODO SERVER IMPLEMENTATION
  }

  void joinRoom(GameRoom room) {
    currentRoom = room;

    //TODO SERVER IMPLEMENTATION
  }

  void _receivedRoomList(List<GameRoom> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

  void createRoom(GameCreationQuery creationQuery) {
    _socket.emit(RoomSocketEvent.CreateWaitingRoom.event, creationQuery);

    // Temperary
    currentRoom = GameRoom(
        id: "-",
        players: [RoomPlayer(creationQuery.user, "-", "-", PlayerType.User, true)],
        dictionary: creationQuery.dictionary,
        timer: creationQuery.timer,
        gameMode: creationQuery.gameMode,
        visibility: creationQuery.visibility);
  }

  void exitRoom(){
    UserRoomQuery exitQuery = UserRoomQuery(user: _authService.user!, roomId: currentRoom!.id);
    _socket.emit(RoomSocketEvent.ExitWaitingRoom.event, exitQuery);
  }


}
