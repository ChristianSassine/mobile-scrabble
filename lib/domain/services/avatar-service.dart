import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/image-type-enum.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/models/userimageinfo-model.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:path/path.dart';

class AvatarService {
  final httpService = GetIt.I.get<HttpHandlerService>();

  Future<dynamic> getDefaultAvatars() async {
    var response = await httpService.getDefaultAvatarsRequest();
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      throw("error");
    }
  }

  Future<AvatarData> formatAvatarData(AvatarData data) async {
    AvatarData avatar = AvatarData(data.type, name: data.name);

    if (avatar.type == ImageType.UrlImage) {
      avatar.url = data.file!.path;
    }
    else {
      avatar.name = basename(data.file!.path);
      avatar.file = data.file;
    }
    return avatar;
  }

  UserImageInfo generateImageInfo(AvatarData data) {
    final isDefault = data.type == ImageType.UrlImage;
    return UserImageInfo(data.name!, isDefault, key: data.url);
  }
}
