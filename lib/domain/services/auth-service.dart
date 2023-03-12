import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  String? username;
  final httpService = GetIt.I.get<HttpHandlerService>();

  // I don't like doing a lot of subjects but it works for now
  Subject<bool> notifyLogin = PublishSubject();
  Subject<bool> notifyLogout = PublishSubject();
  Subject<String> notifyError = PublishSubject();

  Future<void> connectUser(String username, String password) async {
    await httpService
        .signInRequest({"username": username, "password": password});
  }
}
