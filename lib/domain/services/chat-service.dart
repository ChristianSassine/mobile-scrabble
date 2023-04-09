import 'dart:collection';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  Socket socket = GetIt.I.get<Socket>();
  final UserService _userService = GetIt.I.get<UserService>();
  ChatBox chatBox = ChatBox(); // Might need to use something else

  String? currentRoom; // Might change type
  final availableRooms = [];
  var joinedRooms = [];
  final _notifiedRooms =
      HashSet(); // Contains name of currently notified rooms

  ChatService() {
    initSocketListeners();
  }

  void initSocketListeners() {
    // TODO: Implement
    socket.on(ChatRoomSocketEvents.GetAllChatRooms.event, (data) => _getChatRooms(data));
  }

  _getChatRooms(data) { // TODO: replace with chatroom arrray
    (data as List).where((element) => joinedRooms.contains(element)).toList();

    // Remove from joined rooms if it doesn't exist anymore (Edge case)
    final tempHashSet = _notifiedRooms;
    for (var element in (data as List)){
      tempHashSet.remove(element);
    }

    joinedRooms = data;
  }

  bool roomUnread(String roomId) {
    return _notifiedRooms.contains(roomId);
  }

  void joinChatRoom() {
    // TODO: Implement
  }

  void submitMessage(String msg) {
    // TODO : Implement
  }

  // void requestFetchMessages() {
  //   //NEED SERVER IMPLEMENTATION
  // }

  void _emptyMessages() {
    chatBox.messages = [];
  }

  void _receivedMessage(ChatMessage incommingMessage) {
    // TODO: Implement and take into account notifications
    // if (incommingMessage.username != authService.user!.username) {
    //   chatBox.addMessage(incommingMessage);
    // }
  }

  void _userJoined(String username) {
    // TODO: Adapt or remove this
    // if (authService.user!.username != username) {
    //   chatBox.addMessage(ChatMessage(
    //       "",
    //       MessageType.SYSTEM.value,
    //       "${username} has joined the chat",
    //       DateFormat.Hms().format(DateTime.now())));
    // }
  }
}
