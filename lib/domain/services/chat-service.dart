import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';


class ChatService {
  Socket socket = GetIt.I.get<Socket>();
  AuthService authService = GetIt.I.get<AuthService>();
  ChatBox chatBox = ChatBox();

  ChatService() {
    initSocketListeners();
  }

  void initSocketListeners() {
    socket.on(
        RoomSocketEvents.userLeftHomeRoom.event, (data) => {_userLeft(data)});
    socket.on(RoomSocketEvents.UserJoinedRoom.event, (data) => {});

    socket.on(RoomSocketEvents.BroadCastMessageHome.event,
            (data) => {
          _receivedMessage(ChatMessage.fromJson(data))
        });
    socket.on(
        RoomSocketEvents.UserJoinedRoom.event, (data) => {_userJoined(data)});

  }

  void submitMessage(String msg) {
    ChatMessage newMessage =
        ChatMessage(authService.username!, MessageType.CLIENT.value, msg, DateFormat.jms().format(DateTime.now()));
    chatBox.addMessage(newMessage);
    socket.emit(RoomSocketEvents.SendHomeMessage.event, newMessage);
  }

  // void requestFetchMessages() {
  //   //NEED SERVER IMPLEMENTATION
  // }

  void _receivedMessage(ChatMessage incommingMessage) {
    if (incommingMessage.username != authService.username!) {
      chatBox.addMessage(incommingMessage);
    }
  }

  void _userJoined(String username) {
    if (authService.username! != username) {
      chatBox.addMessage(ChatMessage("", MessageType.SYSTEM.value, "${username} has joined the chat", DateFormat.jms().format(DateTime.now())));
    }
  }

  void _userLeft(String username) {}
}
