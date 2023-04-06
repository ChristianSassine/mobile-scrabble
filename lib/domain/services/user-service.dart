import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/models/user-profile-models.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile/domain/enums/server-errors-enum.dart';

class UserService {
  IUser? user;
  final _avatarService = GetIt.I.get<AvatarService>();
  final _httpService = GetIt.I.get<HttpHandlerService>();
  final PublishSubject<bool> notifyChange = PublishSubject();

  // Data collections
  Future<Response>? histories;
  Future<Response>? stats;

  Future<void> changeUserAvatar(AvatarData data) async {
    final newUser = await _avatarService.changeAvatar(data);
    if (newUser == null) {
      notifyChange.add(false);
      return;
    }
    updateUser(newUser);
    notifyChange.add(true);
  }

  void fetchHistories() {
    debugPrint("Fetching histories...");
    histories = _httpService.fetchHistoriesRequest();
  }

  void fetchStats() {
    debugPrint("Fetching stats...");
    stats = _httpService.fetchStatsRequest();
  }

  Future<UserStats> getStats() async {
    if (stats == null) {
      fetchStats();
    }
    final response = await stats;
    if (response!.statusCode == HttpStatus.ok) {
      final userStats = UserStats.fromJson(jsonDecode(response.body));
      return userStats;
    }
    throw ("failed to fetch stats");
  }

  Future<int> getScore() async {
    if (stats == null) {
      fetchStats();
    }
    final response = await stats;
    if (response!.statusCode == HttpStatus.ok) {
      return UserStats.fromJson(jsonDecode(response.body)).totalGameScore;
    }
    throw ("failed to fetch stats");
  }

  Future<List<ConnectionHistory>> getConnections() async {
    if (histories == null) {
      fetchHistories();
    }
    final response = await histories;
    if (response!.statusCode == HttpStatus.ok) {
      final eventsList = jsonDecode(response.body)['historyEventList'] as List;
      final connections = eventsList
          .map((event) => HistoryEvent.fromJson(event))
          .toList()
          .where((element) =>
              element.event == HistoryAction.Connection ||
              element.event == HistoryAction.Logout)
          .map((e) => ConnectionHistory.fromEvent(e))
          .toList();
      return connections.reversed.toList();
    }
    throw ("failed to fetch histories");
  }

  Future<List<MatchHistory>> getMatches() async {
    if (histories == null) {
      fetchHistories();
    }
    final response = await histories;
    if (response!.statusCode == HttpStatus.ok) {
      final eventsList = jsonDecode(response.body)['historyEventList'] as List;
      final matches = eventsList
          .map((event) => HistoryEvent.fromJson(event))
          .toList()
          .where((element) => element.event == HistoryAction.Game)
          .map((event) => MatchHistory.fromEvent(event))
          .toList();
      return matches.reversed.toList();
    }
    throw ("failed to fetch histories");
  }

  Future<void> updateUser(IUser? newUser) async {
    debugPrint("Updating user...");
    user = newUser;
    if (newUser == null) return;
    final urlResponse = await _httpService.getProfilePicture();
    user!.profilePicture!.key = jsonDecode(urlResponse.body)['url'];
  }

  // Modify username and password

  Future<ServerError> modifyUsername(String newUsername) async {
    final response =
        await _httpService.modifyUsernameRequest({'newUsername': newUsername});

    if (response.statusCode == HttpStatus.ok) {
      return ServerError.UsernameChangeSucess;
    } else if (response.statusCode == HttpStatus.conflict) {
      return ServerError.UsernameExistsError;
    } else {
      return ServerError.UsernameChangeError;
    }
  }

  Future<ServerError> modifyPassword(String newPassword) async {
    final response =
        await _httpService.modifyPasswordRequest({'newPassword': newPassword});
    if (response.statusCode == HttpStatus.ok) {
      return ServerError.PasswordChangeSucess;
    } else if (response.statusCode == HttpStatus.conflict) {
      return ServerError.PasswordSameError;
    } else {
      return ServerError.PasswordChangeError;
    }
  }
}
