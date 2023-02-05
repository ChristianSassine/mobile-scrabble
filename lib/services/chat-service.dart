import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum RoomSocketEvents {
  JoinHomeRoom('joinHomeRoom'),
  JoinedHomeRoom('joinedHomeRoom'),
  RoomIsFull('roomIsFull'),
  SendHomeMessage('sendHomeMessage'),
  BroadCastMessageHome('broadcastMessageHome'),
  LeaveHomeRoom('leaveHomeROOM'),
  userLeftHomeRoom('userLeftHomeRoom');

  const RoomSocketEvents(this.event);

  final String event;
}

class ChatService {
  late Socket socket;
  var username = Null;

  ChatService() {
    // Get shared socket
    socket = GetIt.I<Socket>();
    initSocketListeners();
  }

  void initSocketListeners() {
    socket.on(RoomSocketEvents.BroadCastMessageHome.event,
        (data) => {_receiveMessage(data)});
    // Missing userJoinedHomeRoom event on server
    socket.on(
        RoomSocketEvents.userLeftHomeRoom.event, (data) => {_userLeft(data)});
  }

  void joinRoom(String username) {
    socket.on(RoomSocketEvents.JoinedHomeRoom.event, (data) => {});
    socket.on(
        RoomSocketEvents.RoomIsFull.event, (data) => {_joinedRoomFailed()});
    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
  }

  void sendMessage(String newMessage) {
    socket.emit(RoomSocketEvents.SendHomeMessage.event, newMessage);
  }

  void requestFetchMessages() {
    //NEED SERVER IMPLEMENTATION
  }

  void _joinedRoomSuccess() {}

  void _joinedRoomFailed() {}

  void _receiveMessage(String newMessage) {}

  void _userJoined(String username) {}

  void _userLeft(String username) {}
}
