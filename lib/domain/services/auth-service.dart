import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:mobile/domain/services/settings-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AuthService {
  Cookie? _cookie;

  // Services
  final _httpService = GetIt.I.get<HttpHandlerService>();
  final _userService = GetIt.I.get<UserService>();
  final _avatarService = GetIt.I.get<AvatarService>();
  final _chatService = GetIt.I.get<ChatService>();
  final _settingsService = GetIt.I.get<SettingsService>();
  final _socket = GetIt.I.get<Socket>();

  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<bool> notifyRegister = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  AuthService() {
    _initSocketSubs();
  }

  void _initSocketSubs() {
    _socket.on(ConnectionEvent.SuccessfulConnection.event, (_) {
      notifyLogin.add(true);
      _chatService.playNotifSound();
    });

    _socket.on(ConnectionEvent.UserAlreadyConnected.event, (_) {
      disconnect();
      notifyError.add("auth.login.user_taken");
    });
  }

  Future<void> connectUser(String username, String password,
      {accountSetup = false}) async {
    try {
      var response = await _httpService
          .signInRequest({"username": username, "password": password});
      if (response.statusCode == HttpStatus.ok) {
        // JWT token
        String? rawCookie = response.headers['set-cookie'];
        _cookie = Cookie.fromSetCookieValue(rawCookie!);
        _httpService.updateCookie(_cookie!);

        final data = jsonDecode(response.body)['userData'];
        IUser user = IUser.fromJson(data);
        await _userService.updateUser(user);
        if (!accountSetup) {
          try {
            final SettingsInfo settingsInfo = SettingsInfo.fromJson(data);
            _settingsService.loadConfig(settingsInfo);
          } catch (e) {
            debugPrint('Failed to load config');
          }
        }

        final chatrooms = (data['chatRooms'] as List)
            .map((room) => ChatRoomState.fromJson(room))
            .toList();
        _chatService.config(chatrooms);

        if (!accountSetup) _connectSockets();
        return;
      }
    } catch (_) {
      debugPrint("Server not responding...");
      // Server not responding...
    }
    notifyError.add("auth.login.failure");
  }

  Future<void> createUser(
      String username, String email, String password, AvatarData data) async {
    final avatarData = await _avatarService.formatAvatarData(data);
    final profileImageInfo = _avatarService.generateImageInfo(avatarData);

    final signUpForm = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      "profilePicture": profileImageInfo
    });

    var response = await _httpService.signUpRequest(signUpForm);

    if (response.statusCode == HttpStatus.ok) {
      if (data.type == ImageType.DataImage) {
        final String imageKey = jsonDecode(response.body)['imageKey'];
        await _httpService.sendAvatarRequest(data.file!, imageKey);
      }
      notifyRegister.add(true);

      await connectUser(username, password, accountSetup: true);
      await _settingsService.saveConfig();
      _connectSockets();

      return;
    }
    notifyError.add("auth.signup.failure");
  }

  void _connectSockets() {
    _socket.io.options['extraHeaders'] = {'cookie': _cookie};
    _socket
      ..disconnect()
      ..connect();
  }

  void disconnect() {
    _userService.updateUser(null);
    _cookie = null;
    _httpService.resetCookie();
    _chatService.reset();
    _socket.disconnect();
  }
}
