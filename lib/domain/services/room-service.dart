import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/player-models.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  // Socket _socket = GetIt.I.get<Socket>();
  AuthService _authService = GetIt.I.get<AuthService>();
  List<Room> roomList = [];
  Room? currentRoom;
  Subject<List<Room>> notifyNewRoomList = PublishSubject();
  Subject<Room> notifyRoomMemberList = PublishSubject();

  RoomService() {
    // FOR TESTING
    roomList.add(Room("TEST ROOM", RoomType.PUBLIC, [Player(_authService.username),Player("TEST PLAYER2"),Player("TEST PLAYER3"),Player("TEST PLAYER4"),]));

    initSocketListeners();
  }

  void initSocketListeners() {
    // TODO SERVER IMPLEMENTATION
  }

  void updateRoomList() {
    // TODO SERVER IMPLEMENTATION
  }

  void joinRoom(Room room){
    currentRoom = room;

    //TODO SERVER IMPLEMENTATION
  }

  void _receivedRoomList(List<Room> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

  void createRoom(Room room) {
    room.playerList.add(Player(_authService.username!));
    currentRoom = room;
  }

}
