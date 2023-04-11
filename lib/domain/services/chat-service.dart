import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  Socket socket = GetIt.I.get<Socket>();
  final _userService = GetIt.I.get<UserService>();

  // DataStructures
  ChatRoom? currentRoom; // Might change type
  List<ChatMessage> messages = [];
  List<ChatRoom> _chatRooms = [];
  final HashSet<String> _joinedRooms = HashSet();
  final HashSet<String> _notifiedRooms =
      HashSet(); // Contains name of currently notified rooms

  // Observables
  final PublishSubject<ChatRoom> notifyJoinRoom = PublishSubject();
  final PublishSubject<bool> notifyLeftRoom =
      PublishSubject(); // TODO: maybe use this, maybe not
  final PublishSubject<ChatRoom> notifyKickedOut = PublishSubject();
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

  void reset() {
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

    socket.on(ChatRoomSocketEvents.CreateChatRoom.event, (data) {
      final ChatRoom newRoom = ChatRoom.fromJson(data);
      _onNewChatRoomCreated(newRoom);
    });

    socket.on(ChatRoomSocketEvents.CreateChatRoomError.event, (data) {
      final String name = data as String;
      _onRoomCreationFail(name);
    });

    socket.on(ChatRoomSocketEvents.LeaveChatRoom.event, (data) {
      final room = ChatRoom.fromJson(data);
      _leaveRoom(room.name);
    });

    socket.on(ChatRoomSocketEvents.DeleteChatRoom.event, (data) {
      final room = ChatRoom.fromJson(data);
      _deleteChatRoom(room);
    });
  }

  void requestLeaveRoom(String name) {
    requestLeaveRoomSession();
    currentRoom = null;
    socket.emit(ChatRoomSocketEvents.LeaveChatRoom.event, name);
  }

  void _leaveRoom(String name){
    _joinedRooms.remove(name);
    notifyUpdatedChatrooms.add(true);
  }

  void _deleteChatRoom(ChatRoom room){
    _joinedRooms.remove(room.name);
    _chatRooms.removeWhere((chatRoom) => chatRoom.name == room.name);
    if (currentRoom?.name == room.name)  notifyKickedOut.add(room);
    notifyUpdatedChatrooms.add(true);
  }

  void createChatRoom(String name){
    socket.emit(ChatRoomSocketEvents.CreateChatRoom.event, name);
  }

  void _onRoomCreationFail(String name) {
    _joinedRooms.remove(name);
    // TODO : Add showing error
  }

  void _onNewChatRoomCreated(ChatRoom newRoom) {
    _chatRooms.add(newRoom);
    notifyUpdatedChatrooms.add(true);
  }

  void _updateChatRooms(List<ChatRoom> chatrooms) {
    _chatRooms = chatrooms;
    notifyUpdatedChatrooms.add(true);
  }

  void requestJoinRoomSession(ChatRoom room) {
    socket.emit(ChatRoomSocketEvents.JoinChatRoomSession.event, room.name);
  }

  void _joinRoomSession(String roomName, List<ChatMessage> newMessages) {
    currentRoom = _chatRooms.firstWhere((element) => element.name == roomName);
    messages = newMessages;
    notifyJoinRoom.add(currentRoom!);
  }

  void quitRoom() {
    requestLeaveRoomSession();
    currentRoom = null;
  }

  void requestLeaveRoomSession() {
    inRoom = false;
    socket.emit(
        ChatRoomSocketEvents.LeaveChatRoomSession.event, currentRoom!.name);
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
    if (roomName == currentRoom?.name && inRoom) {
      messages.add(message);
      notifyUpdateMessages.add(messages);
      return;
    }
    if (_joinedRooms.contains(roomName)) _notifiedRooms.add(roomName);
    notifyNotificationsUpdate.add(roomName);
  }

  bool isRoomUnread(String roomId) {
    return _notifiedRooms.contains(roomId);
  }

  bool isRoomOwner() {
    return currentRoom?.creatorId == _userService.user!.id;
  }

  void onInRoom() {
    inRoom = true;
    _notifiedRooms.remove(currentRoom?.name);
  }

  void onClosingRoom() {
    inRoom = false;
    requestLeaveRoomSession();
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

    // _sanitizeRooms(rooms) {
    //   // TODO: might be removed
    //   // Remove from joined rooms if it doesn't exist anymore (Edge case)
    //   final tempHashSet = _notifiedRooms;
    //   for (var element in rooms) {
    //     tempHashSet.remove(element.name);
    //   }
    // }
  }
}
