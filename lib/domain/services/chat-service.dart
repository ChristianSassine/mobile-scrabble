import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  Socket socket = GetIt.I.get<Socket>();

  // DataStructures
  ChatRoom? currentRoom; // Might change type
  List<ChatMessage> messages = [];
  List<ChatRoom> _chatRooms = [];
  final HashSet<String> _joinedRooms = HashSet();
  final HashSet<String> _notifiedRooms =
      HashSet(); // Contains name of currently notified rooms

  // Observables
  final PublishSubject<ChatRoom> notifyJoinRoom = PublishSubject();
  final PublishSubject<bool> notifyLeftRoom = PublishSubject(); // TODO: maybe use this, maybe not
  final PublishSubject<bool> notifyUpdatedChatrooms = PublishSubject();
  final PublishSubject<List<ChatMessage>> notifyUpdateMessages =
      PublishSubject();
  final PublishSubject<String> notifyNotificationsUpdate = PublishSubject();

  // Is the sideChatOpen
  bool inRoom = false;

  ChatService() {
    initSocketListeners();
  }

  void init(List<String> joinedChatRooms) {
    _joinedRooms.addAll(joinedChatRooms);
    socket.emit(ChatRoomSocketEvents.GetAllChatRooms.event);
  }

  void reset(){
    _chatRooms = [];
    currentRoom = null;
    _joinedRooms.clear();
    _notifiedRooms.clear();
    messages = [];
  }

  // Getters
  get availableRooms =>
      _chatRooms.where((e) => !_joinedRooms.contains(e.name)).toList();

  get joinedRooms =>
      _chatRooms.where((e) => _joinedRooms.contains(e.name)).toList();

  void initSocketListeners() {
    // TODO: Implement
    socket.on(ChatRoomSocketEvents.GetAllChatRooms.event, (data) {
      final chatrooms =
          (data as List).map((e) => ChatRoom.fromJson(e)).toList();
      _updateChatRooms(chatrooms);
    });

    socket.on(ChatRoomSocketEvents.SendMessage.event, (data) {
      final message = ChatMessage.fromJson(data['newMessage']);
      final roomName = data['room'];
      _treatReceivedMessage(roomName, message);
    });

    socket.on(ChatRoomSocketEvents.JoinChatRoom.event, (data) {
      final room = ChatRoom.fromJson(data);
      _joinChatRoom(room.name);
    });

    socket.on(ChatRoomSocketEvents.JoinChatRoomSession.event, (data) {
      final String roomName = data['name'];
      final List<ChatMessage> newMessages = (data['messages'] as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList();
      _joinRoomSession(roomName, newMessages);
    });

    // TODO: Wait for implementation
    // socket.on(ChatRoomSocketEvents.GetRoomMessages.event, (data) {
    //   messages = (data as List).map((message) => ChatMessage.fromJson(message)).toList();
    // });
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

  bool isRoomUnread(String roomId) {
    return _notifiedRooms.contains(roomId);
  }

  void requestJoinRoomSession(ChatRoom room) {
    socket.emit(ChatRoomSocketEvents.JoinChatRoomSession.event, room.name);
  }

  void _joinRoomSession(String roomName, List<ChatMessage> newMessages) {
    currentRoom = _chatRooms.firstWhere((element) => element.name == roomName);
    messages = newMessages;
    notifyJoinRoom.add(currentRoom!);
  }

  void requestLeaveRoomSession() {
    // TODO: Implement
    socket.emit(ChatRoomSocketEvents.LeaveChatRoomSession.event, currentRoom!.name);
  }

  // TODO: Maybe remove this if it's not useful
  void _leaveRoomSession() {
    notifyLeftRoom.add(true);
  }

  void requestJoinChatRoom(String roomName) {
    // TODO: Implement
    socket.emit(ChatRoomSocketEvents.JoinChatRoom.event, roomName);
  }

  void _joinChatRoom(String roomName) {
    _joinedRooms.add(roomName);
    notifyUpdatedChatrooms.add(true);
  }

  void leaveChatRoom() {
    // TODO: Implement
    socket.emit(ChatRoomSocketEvents.JoinChatRoom.event, currentRoom!.name);
  }

  void submitMessage(String msg) {
    socket
        .emit(ChatRoomSocketEvents.SendMessage.event, [currentRoom?.name, msg]);
  }

  void _treatReceivedMessage(String roomName, ChatMessage message) {
    // TODO: Implement and take into account notifications
    debugPrint("received message from ${message.userId} :  ${message.message}");
    if (roomName == currentRoom?.name) {
      messages.add(message);
      notifyUpdateMessages.add(messages);
      return;
    }
    if (_joinedRooms.contains(roomName)) _notifiedRooms.add(roomName);
    notifyNotificationsUpdate.add(roomName);
  }

  // void requestFetchMessages() {
  //   //NEED SERVER IMPLEMENTATION
  // }

  void signalInRoom(){
    inRoom = true;
  }

  void signalClosingRoom(){
    inRoom = false;
    requestLeaveRoomSession();
  }

  void _emptyMessages() {
    messages = [];
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
