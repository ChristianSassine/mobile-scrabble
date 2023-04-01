import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';

// TODO : move user logic to this service
class UserService{
  IUser? user;
  final _avatarService = GetIt.I.get<AvatarService>();
  final _httpService = GetIt.I.get<HttpHandlerService>();

  Future<void> changeUserAvatar(AvatarData data) async {
    final newUser = await _avatarService.changeAvatar(data);
    if (newUser == null) return;
    user = newUser;
  }

  Future<void> updateUser(IUser? newUser) async {
    user = newUser;
    if (newUser == null) return;
    final urlResponse = await _httpService.getProfilePicture();
    user!.profilePicture!.key = jsonDecode(urlResponse.body)['url'];
  }
}
