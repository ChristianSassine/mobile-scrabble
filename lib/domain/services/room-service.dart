import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/models/joingameparams-model.dart';
import 'package:mobile/domain/models/userimageinfo-model.dart';
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
      // TODO: Use this when the server is updated
      final players =
          (data as List<dynamic>).map((e) => IUser.fromJson(e)).toList();
      debugPrint("Join Room request accepted");
      _joinRoom(players);
    });
  }

  void _updateRoomList(List<Room> newRooms) {
    roomList = newRooms;
    notifyNewRoomList.add(newRooms);
  }

  void requestJoinRoom(Room room) {
    //TODO SERVER IMPLEMENTATION
    selectedRoom = room;

    // TODO: Replace with real image info (Avatar still has to be implemented)
    final image = {
      "name": "default-spongebob",
      "isDefaultPicture": true,
      "key":
          "https://scrabble-images.s3.ca-central-1.amazonaws.com/9e96a2f6-c6f4-4221-bea8-a01f62ba2255default-spongebob.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIA5IBYO7WFXIYKAMR6%2F20230322%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Date=20230322T024825Z&X-Amz-Expires=3600&X-Amz-Signature=516145eb31313f7f4fd1db6d43c3b46bb909d4ec80863930e490f24edada1ebf&X-Amz-SignedHeaders=host&x-id=GetObject"
    };
    final userImage = UserImageInfo(
        image['name'] as String, image['isDefaultPicture'] as bool,
        key: image['key'] as String);
    // -------------------------------------------------------------------------

    final params = JoinGameParams(
        room.id, IUser(_authService.username!, profilePicture: userImage));
    _socket.emit(SocketEvents.PlayerJoinGameAvailable.event, params);
  }

  void exitWaitingRoom() {
    debugPrint('Left waiting room');

    final payload = {
      "roomId" : selectedRoom!.id,
      "player" : IUser(_authService.username!)
    };
    _socket.emit(SocketEvents.ExitWaitingRoom.event, payload);
  }

  void _joinRoom(List<IUser> players) {
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
