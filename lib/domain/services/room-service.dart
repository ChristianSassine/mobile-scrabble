import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  Socket socket = GetIt.I.get<Socket>();
  List<Room> roomList = [];
  Room? selectedRoom;
  Subject<List<Room>> notifyNewRoomList = PublishSubject();
  Subject<Room> notifyRoomMemberList = PublishSubject();

  RoomService() {
    // FOR TESTING
    roomList.add(Room("TEST ROOM", RoomType.PUBLIC, ["TEST PLAYER"]));

    initSocketListeners();
  }

  void initSocketListeners() {
    // TODO SERVER IMPLEMENTATION
  }

  void updateRoomList() {
    // TODO SERVER IMPLEMENTATION
  }

  void joinRoom(Room room){
    selectedRoom = room;

    //TODO SERVER IMPLEMENTATION
  }

  void _receivedRoomList(List<Room> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

}