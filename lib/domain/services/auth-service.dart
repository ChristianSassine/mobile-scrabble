import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
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
  final _socket = GetIt.I.get<Socket>();

  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<bool> notifyRegister = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  Future<void> connectUser(String username, String password) async {
    try {
      var response = await _httpService
          .signInRequest({"username": username, "password": password});

      if (response.statusCode == HttpStatus.ok) {
        // JWT token
        String? rawCookie = response.headers['set-cookie'];
        _cookie = Cookie.fromSetCookieValue(rawCookie!);
        _httpService.updateCookie(_cookie!);

        IUser user = IUser.fromJson(jsonDecode(response.body)['userData']);
        await _userService.updateUser(user);

        _socket.io.options['extraHeaders'] = {'cookie': _cookie};
        _socket
          ..disconnect()
          ..connect();

        _chatService.init();
        notifyLogin.add(true);
        return;
      }
    } catch (_) {
      // Server not responding...
    }
    notifyError.add("Failed Login");
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
    }); // TODO: Make a model later maybe? (Will only be used here)

    var response = await _httpService.signUpRequest(signUpForm);

    if (response.statusCode == HttpStatus.ok) {
      if (data.type == ImageType.DataImage) {
        final String imageKey = jsonDecode(response.body)['imageKey'];
        await _httpService.sendAvatarRequest(data.file!, imageKey);
      }
      notifyRegister.add(true);

      await connectUser(username, password);
      return;
    }
    notifyError.add("Failed Login");
  }

  void diconnect() {
    _userService.updateUser(null);
    _cookie = null;
    _socket.disconnect();
  }
}
