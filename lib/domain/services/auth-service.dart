import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../enums/socket-events-enum.dart';

class AuthService {
  String? username = null;
  Socket socket = GetIt.I.get<Socket>();
  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = ReplaySubject(maxSize: 0);
  Subject<bool> notifyLogout = ReplaySubject(maxSize: 0);
  Subject<String> notifyError = ReplaySubject(maxSize: 0);

  void initSockets() {
    socket.on(
        RoomSocketEvents.UserJoinedRoom.event,
            (data) => {
          if (data == username) {_joinedRoomSuccess(data)}
        });
    socket.on(RoomSocketEvents.RoomIsFull.event,
            (data) => {_joinedRoomFailed(RoomJoinFailureReason.FULL)});
  }

  // To change in the future to be more general
  void connectUser(String username) {
    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
  }

  void disconnect() {
    socket.emit(RoomSocketEvents.LeaveHomeRoom.event);
    notifyLogout.add(true);
  }

  bool isConnected () {
    return username != null;
  }

  // Joined rooms in the future will just be for connecting the users and not the rooms
  void _joinedRoomSuccess(String username) {
    print("Success to join room!");
    this.username = username;
    this.notifyLogin.add(true);
  }

  void _joinedRoomFailed(RoomJoinFailureReason reason) {
    switch (reason) {
      case RoomJoinFailureReason.FULL:
        const message = "Failed to join room: Room is full!";
        notifyError.add(message);
        print(message);
        break;
      case RoomJoinFailureReason.USERNAME_TAKEN:
        const message = "Failed to join room: Username already taken!";
        notifyError.add(message);
        print(message);
    }
  }
}
