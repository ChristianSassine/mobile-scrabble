import 'dart:collection';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  Socket socket = GetIt.I.get<Socket>();
  ChatBox chatBox = ChatBox(); // Might need to use something else

  ChatRoom? currentRoom; // Might change type
  List<ChatRoom> _chatRooms = [];
  final HashSet<String> _joinedRooms = HashSet();
  final HashSet<String> _notifiedRooms = HashSet(); // Contains name of currently notified rooms

  // Observables
  final PublishSubject<bool> notifyUpdatedChatrooms = PublishSubject();

  ChatService() {
    _joinedRooms.add('main'); // TODO : might do this differently
    initSocketListeners();
  }

  void init() {
    socket.emit(ChatRoomSocketEvents.GetAllChatRooms.event);
  }

  // Getters
  get availableRooms => _chatRooms.where((e) => !_joinedRooms.contains(e.name)).toList();
  get joinedRooms => _chatRooms.where((e) => _joinedRooms.contains(e.name)).toList();

  void initSocketListeners() {
    // TODO: Implement
    socket.on(ChatRoomSocketEvents.GetAllChatRooms.event, (data) {
      final chatrooms = (data as List).map((e) => ChatRoom.fromJson(e)).toList();
      _updateChatRooms(chatrooms);
    });
  }

  void _updateChatRooms(List<ChatRoom> chatrooms) {
    _chatRooms = chatrooms;
    notifyUpdatedChatrooms.add(true);
  }

  _sanitizeRooms(rooms) {
    // TODO: might be removed
    // Remove from joined rooms if it doesn't exist anymore (Edge case)
    final tempHashSet = _notifiedRooms;
    for (var element in rooms) {
      tempHashSet.remove(element.name);
    }
  }

  bool roomUnread(String roomId) {
    return _notifiedRooms.contains(roomId);
  }

  void startReading(){
    // TODO: Implement
  }

  void stopReading(){
    // TODO: Implement

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
