import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

class AuthService {
  String? username;
  Cookie? _cookie;

  // Services
  final _httpService = GetIt.I.get<HttpHandlerService>();
  final _socket = GetIt.I.get<Socket>();

  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  Future<void> connectUser(String username, String password) async {
    var response = await _httpService
        .signInRequest({"username": username, "password": password});

    if (response.statusCode == HttpStatus.ok) {
      // JWT token
      String? rawCookie = response.headers['set-cookie'];
      _cookie = Cookie.fromSetCookieValue(rawCookie!);

      _socket.io.options['extraHeaders'] = {'cookie': _cookie};
      _socket
        ..disconnect()
        ..connect();
      this.username = username;
      notifyLogin.add(true);
      return;
    }
    notifyError.add("Failed Login");
  }

  Future<void> createUser(
      String username, String email, String password) async {
    var response = await _httpService.signUpRequest(
        {"username": username, "email": email, "password": password});

    if (response.statusCode == HttpStatus.ok) {
      await connectUser(username, password);
      return;
    }
    notifyError.add("Failed Login");
  }

  void diconnect() {
    username = null;
    _cookie = null;
    _socket.disconnect();
  }
}
