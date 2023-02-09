import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../enums/socket-events-enum.dart';

// To change in the future to be for an account and not for one chatroom
class AuthService {
  String? username = null;
  Socket socket = GetIt.I.get<Socket>();
  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  AuthService(){
    initSockets();
  }

  void initSockets() {
    socket.on(
        RoomSocketEvents.UserConnected.event,
            (data) => {
          {_joinedRoomSuccess(data)}
        });
    socket.on(RoomSocketEvents.RoomIsFull.event,
            (data) => {_joinedRoomFailed(RoomJoinFailureReason.FULL)});
    socket.on(RoomSocketEvents.usernameTaken.event,
    (data) => {_joinedRoomFailed(RoomJoinFailureReason.USERNAME_TAKEN)});
  }


  void connectUser(String username) {
    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
    print("connecting");
  }

  void disconnect() {
    socket.emit(RoomSocketEvents.LeaveHomeRoom.event);
    username = null;
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
    username = null;
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
