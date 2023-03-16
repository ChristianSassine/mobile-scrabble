import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  String? username;
  final httpService = GetIt.I.get<HttpHandlerService>();
  Cookie cookie = Cookie("", "");

  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  Future<void> connectUser(String username, String password) async {
    var response = await httpService
        .signInRequest({"username": username, "password": password});

    if (response.statusCode == HttpStatus.ok){
      // JWT token
      String? rawCookie = response.headers['set-cookie'];
      cookie = Cookie.fromSetCookieValue(rawCookie!);
      debugPrint("Connected with cookie : $cookie");

      notifyLogin.add(true);
      return;
    }
    notifyError.add("Failed Login");
  }

  Future<void> createUser(String username, String email, String password) async {
    var response = await httpService
        .signUpRequest({"username": username, "email":email, "password": password});

    if (response.statusCode == HttpStatus.ok){
      // JWT token
      String? rawCookie = response.headers['set-cookie'];
      cookie = Cookie.fromSetCookieValue(rawCookie!);
      debugPrint("Connected with cookie : $cookie");

      notifyLogin.add(true);
      return;
    }
    notifyError.add("Failed Login");
  }
}
