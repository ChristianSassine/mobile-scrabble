import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:rxdart/subjects.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/room-model.dart';

class RoomService {
  final Socket _socket = GetIt.I.get<Socket>();
  // AuthService _authService = GetIt.I.get<AuthService>();
  List<Room> roomList = [];
  GameRoom? currentRoom;
  Subject<List<Room>> notifyNewRoomList = PublishSubject();
  Subject<Room> notifyRoomMemberList = PublishSubject();

  RoomService() {
    // FOR TESTING
    roomList.add(Room("TEST ROOM", GameVisibility.Public, ["TEST PLAYER"]));

    initSocketListeners();
  }

  void initSocketListeners() {
    _socket.on(
        RoomSocketEvent.UpdateWaitingRoom.event, (data) => currentRoom = GameRoom.fromJson(data));
  }

  void updateRoomList() {
    // TODO SERVER IMPLEMENTATION
  }

  void joinRoom(Room room) {
    // selectedRoom = room;

    //TODO SERVER IMPLEMENTATION
  }

  void _receivedRoomList(List<Room> incommingRoomList) {
    roomList = incommingRoomList;
    notifyNewRoomList.add(incommingRoomList);
  }

  void createRoom(GameCreationQuery creationQuery) {
    _socket.emit(RoomSocketEvent.CreateWaitingRoom.event, creationQuery);

    currentRoom = GameRoom(id: "-",
        players: [RoomPlayer(creationQuery.user, "-", "-", PlayerType.User, true)],
        dictionary: creationQuery.dictionary,
        timer: creationQuery.timer,
        gameMode: creationQuery.gameMode,
        visibility: creationQuery.visibility);
  }

}
