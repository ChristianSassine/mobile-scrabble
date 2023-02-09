import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../enums/socket-events-enum.dart';

class AuthService {
  String? username = null;
  Socket socket = GetIt.I.get<Socket>();

  void connectUser(String username) {
    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
  }
}
