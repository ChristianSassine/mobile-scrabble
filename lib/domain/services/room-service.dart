import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  final Socket _socket = GetIt.I.get<Socket>();
  final AuthService _authService = GetIt.I.get<AuthService>();
  List<Room> roomList = [];
  Room? selectedRoom;
  Subject<List<Room>> notifyNewRoomList = PublishSubject();
  Subject<Room> notifyRoomMemberList = PublishSubject();

  RoomService() {
    // FOR TESTING
    roomList.add(Room("TEST ROOM", ["TEST PLAYER"], "", 0, RoomType.PUBLIC));
    initSocketListeners();
  }

  void connectToRooms() {
    _socket.emit(RoomSocketEvents.RoomLobby.event);
  }

  void initSocketListeners() {
    // TODO SERVER IMPLEMENTATION
    _socket.on(RoomSocketEvents.UpdateRoomJoinable.event, (data) {
      _updateRoomList(data);
    });
  }

  void _updateRoomList(List<Room> newRooms) {
    // TODO SERVER IMPLEMENTATION
    roomList = newRooms;
    notifyNewRoomList.add(newRooms);
  }

  void joinRoom(Room room){
    selectedRoom = room;

    //TODO SERVER IMPLEMENTATION
  }

  void _receivedRoomList(List<Room> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

  void createRoom(Room room) {
    room.users.add(_authService.username!);
    selectedRoom = room;
  }

}
