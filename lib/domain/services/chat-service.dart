import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/services/audio_service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/chat-models.dart';

class ChatService {
  // Services
  Socket socket = GetIt.I.get<Socket>();
  final _userService = GetIt.I.get<UserService>();
  final _httpService = GetIt.I.get<HttpHandlerService>();
  final _audioService = GetIt.I.get<AudioService>();

  // DataStructures
  ChatRoom? currentRoom; // Might change type
  List<ChatMessage> messages = [];
  List<ChatRoom> _chatRooms = [];
  final HashSet<String> _joinedRooms = HashSet();
  final HashSet<String> _notifiedRooms =
      HashSet(); // Contains name of currently notified rooms
  final HashMap<String, UserChatRoom> usersInfo = HashMap();

  // Observables
  final PublishSubject<ChatRoom> notifyJoinRoom = PublishSubject();
  final PublishSubject<bool> notifyLeftRoom =
      PublishSubject(); // TODO: maybe use this, maybe not
  final PublishSubject<ChatRoom> notifyKickedOut = PublishSubject();
  final PublishSubject<bool> notifyUpdatedChatrooms = PublishSubject();
  final PublishSubject<List<ChatMessage>> notifyUpdateMessages =
      PublishSubject();
  final PublishSubject<bool> notifyUpdatedNotifications = PublishSubject();

  // Is the sideChatOpen
  bool inRoom = false;

  ChatService() {
    initSocketListeners();
  }

  void config(List<ChatRoomState> joinedChatRooms) {
    for (final joinedRoom in joinedChatRooms) {
      _joinedRooms.add(joinedRoom.name);
      if (joinedRoom.notified) _notifiedRooms.add(joinedRoom.name);
    }
    if (_notifiedRooms.isNotEmpty) _audioService.playNotificationSound();
    socket.emit(ChatRoomSocketEvents.GetAllChatRooms.event);
  }

  void reset() {
    _chatRooms = [];
    usersInfo.clear();
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

  get notifsCount => _notifiedRooms.length;

  void initSocketListeners() {
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
      _joinChatRoom(room);
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

  void _leaveRoom(String name) {
    _joinedRooms.remove(name);
    notifyUpdatedChatrooms.add(true);
  }

  void _deleteChatRoom(ChatRoom room) {
    _joinedRooms.remove(room.name);
    _chatRooms.removeWhere((chatRoom) => chatRoom.name == room.name);
    if (currentRoom?.name == room.name) notifyKickedOut.add(room);
    notifyUpdatedChatrooms.add(true);
  }

  void createChatRoom(String name) {
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
    final currentlyRequested = Set();
    for (final message in messages) {
      final id = message.userId;
      if (!usersInfo.containsKey(id) && !currentlyRequested.contains(id)) {
        currentlyRequested.add(id);
        _updateUserInfo(id);
      }
    }
    notifyJoinRoom.add(currentRoom!);
  }

  void _updateUserInfo(String id) {
    _httpService.getChatUserInfoRequest(id).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        final userInfo = UserChatRoom.fromJson(jsonDecode(response.body));
        usersInfo[id] = userInfo;
        notifyUpdateMessages.add(messages);
      }
    });
  }

  void quitRoom() {
    requestLeaveRoomSession();
    currentRoom = null;
  }

  void requestLeaveRoomSession() {
    inRoom = false;
    socket.emit(
        ChatRoomSocketEvents.LeaveChatRoomSession.event, currentRoom!.name);
    usersInfo.clear();
  }

  // TODO: Maybe remove this if it's not useful
  void _leaveRoomSession() {
    notifyLeftRoom.add(true);
  }

  void requestJoinChatRoom(String roomName) {
    // TODO: Implement
    socket.emit(ChatRoomSocketEvents.JoinChatRoom.event, roomName);
  }

  void _joinChatRoom(ChatRoom room) {
    _joinedRooms.add(room.name);
    notifyUpdatedChatrooms.add(true);
    requestJoinRoomSession(room);
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
      if (!usersInfo.containsKey(message.userId))
        _updateUserInfo(message.userId);
      messages.add(message);
      notifyUpdateMessages.add(messages);
      return;
    }
    if (!_joinedRooms.contains(roomName) || _notifiedRooms.contains(roomName))
      return;
    _notifiedRooms.add(roomName);
    _audioService.playNotificationSound();
    notifyUpdatedNotifications.add(true);
    debugPrint("notification count : $notifsCount");
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
    notifyUpdatedNotifications.add(true);
    debugPrint("notification count : $notifsCount");
  }

  void onClosingRoom() {
    inRoom = false;
    requestLeaveRoomSession();
  }
}
