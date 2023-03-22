import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  List<Room> roomList = [];
  Room? selectedRoom;

  // Services
  final Socket _socket = GetIt.I.get<Socket>();
  final AuthService _authService = GetIt.I.get<AuthService>();

  // Observables
  Subject<List<Room>> notifyNewRoomList = PublishSubject();
  Subject<Room> notifyRoomMemberList = PublishSubject();
  Subject<Room> notifyRoomJoin = PublishSubject();

  RoomService() {
    // FOR TESTING
    roomList.add(Room("TEST ROOM", [], "", 0, RoomType.PUBLIC));
    initSocketListeners();
  }

  void connectToRooms() {
    _socket.emit(SocketEvents.RoomLobby.event);
  }

  void initSocketListeners() {
    _socket.on(SocketEvents.UpdateRoomJoinable.event, (data) {
      final newRooms =
          (data as List<dynamic>).map((e) => Room.fromJson(e)).toList();
      _updateRoomList(newRooms);
    });

    _socket.on(SocketEvents.JoinValidGame.event, (data) {
      final players = [data as String];

      // TODO: Use this when the server is updated
      // final players =
      // (data as List<dynamic>).map((e) => e as String).toList();
      debugPrint("Join Room request accepted");
      // _joinRoom(players);
    });
  }

  void _updateRoomList(List<Room> newRooms) {
    roomList = newRooms;
    notifyNewRoomList.add(newRooms);
  }

  void requestJoinRoom(Room room) {
    //TODO SERVER IMPLEMENTATION
    selectedRoom = room;
    _socket.emit(SocketEvents.PlayerJoinGameAvailable.event, {
      "id": room.id,
      "name": _authService.username!
    }); // TODO : Might need to create a model for this later maybe?
  }

  void _joinRoom(List<IUser> players) {
    print(players);
    selectedRoom!.users = [IUser(_authService.username!), ...players];
    print("Room Joined");
  }

  void _receivedRoomList(List<Room> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

  void createRoom(Room room) {
    // room.users.add(IUser("email", _authService.username!));
    selectedRoom = room;
  }
}
