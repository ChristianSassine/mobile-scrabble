import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../enums/socket-events-enum.dart';

enum RoomJoinFailureReason { FULL, USERNAME_TAKEN }

// To change in the future to be for an account and not for one chatroom
class AuthService {
  String? username;
  Socket socket = GetIt.I.get<Socket>();

  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  AuthService() {
    initSockets();
  }

  void initSockets() {
    socket.on(
        RoomSocketEvents.UserJoinedRoom.event,
        (data) => {
              {_joinedRoomSuccess(data)}
            });

    socket.on(RoomSocketEvents.RoomIsFull.event,
        (data) => {_joinedRoomFailed(RoomJoinFailureReason.FULL)});

    socket.on(RoomSocketEvents.usernameTaken.event,
        (data) => {_joinedRoomFailed(RoomJoinFailureReason.USERNAME_TAKEN)});

    socket.on(RoomSocketEvents.userLeftHomeRoom.event,
            (data) => {_leaveRoom(data)});
  }

  void connectUser(String username) {
    // Might need to consider changing this so that we don't need to store the username
    // I think username should be assigned to us from the server when we login
    this.username = username;
    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
    if (kDebugMode) {
      print("connecting");
    }
  }

  void disconnect() {
    socket.emit(RoomSocketEvents.LeaveHomeRoom.event);

  }

  bool isConnected() {
    return username != null;
  }

  void _leaveRoom(String? leavingUser) {
    print("${leavingUser} left");
    if ((leavingUser != null) & (leavingUser == username)) {
      username = null;
      notifyLogout.add(true);
    }
  }

  // Joined rooms in the future will just be for connecting the users and not the rooms
  void _joinedRoomSuccess(String joinedUser) {
    if (joinedUser == username) {
      print("Success to join room!");
      this.username = username;
      notifyLogin.add(true);
    }
  }

  void _joinedRoomFailed(RoomJoinFailureReason reason) {
    username = null;
    switch (reason) {
      case RoomJoinFailureReason.FULL:
        const message = "Failed to join room: Room is full!";
        notifyError.add(message);
        if (kDebugMode) {
          print(message);
        }
        break;
      case RoomJoinFailureReason.USERNAME_TAKEN:
        const message = "Failed to join room: Username already taken!";
        notifyError.add(message);
        if (kDebugMode) {
          print(message);
        }
    }
  }
}
