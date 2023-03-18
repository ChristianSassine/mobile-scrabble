import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/http-handler-service.dart';

class AvatarService {
  final httpService = GetIt.I.get<HttpHandlerService>();

  Future<dynamic> getDefaultAvatars() async {
    var response = await httpService.getDefaultAvatarsRequest();
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return {};
    }
  }
}
