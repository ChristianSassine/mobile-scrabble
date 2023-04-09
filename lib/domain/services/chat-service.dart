import 'dart:collection';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  Socket socket = GetIt.I.get<Socket>();

  ChatRoom? currentRoom; // Might change type
  List<ChatMessage> messages = [];
  List<ChatRoom> _chatRooms = [];
  final HashSet<String> _joinedRooms = HashSet();
  final HashSet<String> _notifiedRooms = HashSet(); // Contains name of currently notified rooms

  // Observables
  final PublishSubject<bool> notifyUpdatedChatrooms = PublishSubject();
  final PublishSubject<List<ChatMessage>> notifyUpdateMessages = PublishSubject();
  final PublishSubject<String> notifyNotificationsUpdate = PublishSubject();

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

    socket.on(ChatRoomSocketEvents.SendMessage.event, (data) {
      final message = ChatMessage.fromJson(data['message']);
      final roomName = data['room'];
      _treatReceivedMessage(roomName, message);
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

  void startReadingRoom(ChatRoom room) {
    // TODO: Implement
    currentRoom = room;
  }

  void stopReadingRoom() {
    // TODO: Implement
    currentRoom = null;
  }

  void joinChatRoom() {
    // TODO: Implement
  }

  void leaveChatRoom() {
    // TODO: Implement
  }

  void submitMessage(String msg) {
    socket.emit(ChatRoomSocketEvents.SendMessage.event, msg);
  }

  // void requestFetchMessages() {
  //   //NEED SERVER IMPLEMENTATION
  // }

  void _emptyMessages() {
    messages = [];
  }

  void _loadMessages() {

  }

  void _treatReceivedMessage(String roomName, ChatMessage message) {
    // TODO: Implement and take into account notifications
    if (roomName == currentRoom?.name){
      messages.add(message);
      notifyUpdateMessages.add(messages);
      return;
    }
    if (_joinedRooms.contains(roomName)) _notifiedRooms.add(roomName);
    notifyNotificationsUpdate.add(roomName);
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
