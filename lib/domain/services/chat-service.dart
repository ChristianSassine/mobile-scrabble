import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

enum RoomSocketEvents {
  JoinHomeRoom('joinHomeRoom'),
  UserJoinedRoom('userJoinedRoom'),
  RoomIsFull('roomIsFull'),
  SendHomeMessage('sendMessageHome'),
  BroadCastMessageHome('broadcastMessageHome'),
  LeaveHomeRoom('leaveHomeRoom'),
  userLeftHomeRoom('userLeftHomeRoom'),
  usernameTaken('usernameTaken');

  const RoomSocketEvents(this.event);

  final String event;
}

enum RoomJoinFailureReason { FULL, USERNAME_TAKEN }

class ChatService {
  Socket socket = GetIt.I.get<Socket>();
  String username = "Gary Anderson";
  ChatBox chatBox = ChatBox();

  ChatService() {
    initSocketListeners();
  }

  void initSocketListeners() {
    socket.on(
        RoomSocketEvents.userLeftHomeRoom.event, (data) => {_userLeft(data)});
  }

  void joinRoom(String username) {
    socket.on(
        RoomSocketEvents.UserJoinedRoom.event, (data) => {_userJoined(data)});
    socket.on(RoomSocketEvents.RoomIsFull.event,
        (data) => {_joinedRoomFailed(RoomJoinFailureReason.FULL)});

    socket.on(
        RoomSocketEvents.UserJoinedRoom.event,
        (data) => {
              if (data == username) {_joinedRoomSuccess(data)}
            });

    socket.emit(RoomSocketEvents.JoinHomeRoom.event, username);
  }

  void submitMessage(String msg) {
    ChatMessage newMessage =
        ChatMessage(username, MessageType.CLIENT.value, msg, DateFormat.jms().format(DateTime.now()));
    chatBox.addMessage(newMessage);
    socket.emit(RoomSocketEvents.SendHomeMessage.event, newMessage);
  }

  // void requestFetchMessages() {
  //   //NEED SERVER IMPLEMENTATION
  // }

  void _joinedRoomSuccess(String username) {
    print("Success to join room!");
    this.username = username;

    socket.on(RoomSocketEvents.UserJoinedRoom.event, (data) => {});

    socket.on(RoomSocketEvents.BroadCastMessageHome.event,
        (data) => {
      _receivedMessage(ChatMessage.fromJson(Map.from(data)))
    });
  }

  void _joinedRoomFailed(RoomJoinFailureReason reason) {
    switch (reason) {
      case RoomJoinFailureReason.FULL:
        print("Failed to join room: Room is full!");
        break;
      case RoomJoinFailureReason.USERNAME_TAKEN:
        print("Failed to join room: Username already taken!");
    }
  }

  void _receivedMessage(ChatMessage incommingMessage) {
    if (incommingMessage.username != username) {
      chatBox.addMessage(incommingMessage);
    }
  }

  void _userJoined(String username) {
    if (this.username != username) {
      chatBox.addMessage(ChatMessage("", MessageType.SYSTEM.value, "${username} has joined the chat", DateFormat.jms().format(DateTime.now())));
    }
  }

  void _userLeft(String username) {}
}
