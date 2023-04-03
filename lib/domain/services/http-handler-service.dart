import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class HttpHandlerService {
  late final http.Client client;
  late final String baseUrl;
  Map<String, String> headers = {};

  HttpHandlerService(String serverAddress) {
    client = http.Client();
    baseUrl = serverAddress;
  }

  Future<http.Response> modifyUsernameRequest(Object body) {
    return client.patch(Uri.parse("${baseUrl}/profile/username"), body: body,
    headers: headers);
  }

  // Auth requests
  Future<http.Response> signInRequest(Object body) {
    return client.post(Uri.parse("${baseUrl}/auth/login"), body: body);
  }

  Future<http.Response> signUpRequest(Object body) {
    return client.post(Uri.parse("${baseUrl}/auth/signUp"),
        headers: {'Content-Type': 'application/json'}, body: body);
  }

  // Profile Avatar requests
  Future<http.Response> getDefaultAvatarsRequest() {
    return client.get(
      Uri.parse("${baseUrl}/image/default-pictures"),
    );
  }

  Future<http.Response> getProfilePicture() {
    return client.get(Uri.parse("$baseUrl/image/profile-picture"),
        headers: headers);
  }

  Future<http.StreamedResponse> sendAvatarRequest(
      File image, String key) async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("${baseUrl}/image/profile-picture"));

    request.headers['Content-Type'] = 'multipart/form-data';

    final imageFile = await http.MultipartFile.fromPath('data', image.path,
        contentType: MediaType("image", "*"));

    request.files.add(imageFile);
    request.fields['ImageKey'] = key;

    final response = await request.send();
    return response;
  }

  // TODO: Test when implementing user profile (changing avatar feature)
  Future<http.Response> updateImageAvatar(String avatarName) {
    print("updateImageAvatar Request sent");
    return client.patch(Uri.parse("$baseUrl/image/profile-picture"),
        body: {"fileName": avatarName}, headers: headers);
  }

  // TODO: Test when implementing user profile (changing avatar feature)
  Future<http.Response> changeImageAvatar(File newAvatarFile) async {
    final request = http.MultipartRequest(
        "PUT", Uri.parse("${baseUrl}/image/profile-picture"));
    request.headers["cookie"] = headers["cookie"]!;
    request.headers['Content-Type'] = 'multipart/form-data';

    final imageFile = await http.MultipartFile.fromPath(
        'image', newAvatarFile.path,
        contentType: MediaType("image", "*"));

    request.files.add(imageFile);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  // High Scores requests
  Future<http.Response> fetchHighScoresRequest() {
    return client.get(Uri.parse("${baseUrl}/highScore/classique"));
  }

  // Common utilities
  void updateCookie(Cookie cookie) {
    headers['cookie'] = "${cookie.name}=${cookie.value}";
  }
}
