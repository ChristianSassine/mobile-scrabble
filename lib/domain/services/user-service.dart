import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/models/user-profile-models.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';

// TODO : move user logic to this service
class UserService{
  IUser? user;
  final _avatarService = GetIt.I.get<AvatarService>();
  final _httpService = GetIt.I.get<HttpHandlerService>();
  final Future<List<HistoryEvent>> histories = <HistoryEvent>[] as Future<List<HistoryEvent>>;

  final mockMatches = [
    MatchHistory(true, '19:30 - 19/03/2022'),
    MatchHistory(false, '18:30 - 19/03/2022'),
    MatchHistory(true, '17:30 - 19/03/2022 ')
  ];

  final mockConnections = [
    ConnectionHistory(true, '19:30 - 19/03/2022'),
    ConnectionHistory(false, '18:30 - 19/03/2022'),
    ConnectionHistory(true, '17:30 - 19/03/2022 ')
  ];

  Future<void> changeUserAvatar(AvatarData data) async {
    final newUser = await _avatarService.changeAvatar(data);
    if (newUser == null) return;
    updateUser(newUser);
  }

  fetchHistories() {
    // TODO: Fetch Histories
  }

  Future<List<ConnectionHistory>> getConnections() async {
    // TODO: Link with server
    return mockConnections;
  }

  Future<List<MatchHistory>> getMatches() async {
    // TODO: Link with server
    return mockMatches;
  }

  Future<void> updateUser(IUser? newUser) async {
    debugPrint("Updating user...");
    user = newUser;
    if (newUser == null) return;
    final urlResponse = await _httpService.getProfilePicture();
    user!.profilePicture!.key = jsonDecode(urlResponse.body)['url'];
  }
}
