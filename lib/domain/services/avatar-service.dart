import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/models/user-image-info-model.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class AvatarService {
  final httpService = GetIt.I.get<HttpHandlerService>();

  String? _botImageUrl;
  final notifyBotImageUrl = PublishSubject<String>();

  AvatarService() {
    _initBotImage();
  }

  get botImageUrl {
    if (_botImageUrl == null) {
      _initBotImage();
    }
    return _botImageUrl;
  }

  void _initBotImage() async {
    var response = await httpService.getBotProfilePicture();

    if (response.statusCode == 200) {
      _botImageUrl = jsonDecode(response.body)['url'];
      notifyBotImageUrl.add(botImageUrl!);
    }
  }

  Future<dynamic> getDefaultAvatars() async {
    var response = await httpService.getDefaultAvatarsRequest();
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      debugPrint('Request failed with status: ${response.statusCode}.');
      throw ("error");
    }
  }

  Future<AvatarData> formatAvatarData(AvatarData data) async {
    AvatarData avatar = AvatarData(data.type, name: data.name);

    if (avatar.type == ImageType.UrlImage) {
      avatar.url = data.file!.path;
    } else {
      avatar.name = basename(data.file!.path);
      avatar.file = data.file;
    }
    return avatar;
  }

  Future<IUser?> changeAvatar(AvatarData data) async {
    final avatarData = await formatAvatarData(data);
    IUser? user;
    final response = avatarData.type == ImageType.UrlImage
        ? await httpService.updateImageAvatar(data.name!)
        : await httpService.changeImageAvatar(data.file!);
    if (response.statusCode == HttpStatus.ok) {
      user = IUser.fromJson(jsonDecode(response.body)["userData"]);
    }
    return user;
  }

  UserImageInfo generateImageInfo(AvatarData data) {
    final isDefault = data.type == ImageType.UrlImage;
    return UserImageInfo(data.name!, isDefault, key: data.url);
  }
}
