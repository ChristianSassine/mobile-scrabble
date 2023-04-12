import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';

class HttpHandlerService {
  late final http.Client client;
  late final String baseUrl;
  late final String httpUrl;
  Map<String, String> headers = {};

  HttpHandlerService(String serverAddress, {this.httpUrl = ''}) {
    init();
    baseUrl = serverAddress;
  }

  void init() async {
    var context = SecurityContext(withTrustedRoots: false);

    final List<int> certificateChainBytes =
        (await rootBundle.load('assets/certs/server.pem')).buffer.asInt8List();
    context.useCertificateChainBytes(certificateChainBytes);

    final List<int> keyChainBytes =
        (await rootBundle.load('assets/certs/server.key')).buffer.asInt8List();
    context.usePrivateKeyBytes(keyChainBytes);

    HttpClient httpclient = HttpClient(context: context);
    client = IOClient(
        httpclient..badCertificateCallback = ((cert, host, port) => true));
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

  Future<http.Response> getBotProfilePicture() {
    return client.get(Uri.parse("$baseUrl/image/bot/profile-picture"),
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

  Future<http.Response> updateImageAvatar(String avatarName) {
    return client.patch(Uri.parse("$baseUrl/image/profile-picture"),
        body: {"fileName": avatarName}, headers: headers);
  }

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

  // Profile data requests
  Future<http.Response> fetchHistoriesRequest() {
    return client.get(Uri.parse("$baseUrl/profile/history-events"), headers: headers);
  }

  Future<http.Response> fetchStatsRequest() {
    return client.get(Uri.parse("$baseUrl/profile/stats"), headers: headers);
  }

  // Modifying user requests
  Future<http.Response> modifyUsernameRequest(Object body) {
    return client.patch(Uri.parse("$baseUrl/profile/username"),
        body: body, headers: headers);
  }

  Future<http.Response> modifyPasswordRequest(Object body) {
    return client.patch(Uri.parse("$baseUrl/profile/password"),
        body: body, headers: headers);
  }

  // High Scores requests
  Future<http.Response> fetchHighScoresRequest() {
    return client.get(Uri.parse("$baseUrl/highScore/classique"));
  }

  Future<http.Response> fetchDictionaries(){
    return client.get(Uri.parse("$baseUrl/dictionary/info"));
  }

  // App Settings requests
  Future<http.Response> modifyThemeRequest(Object body) {
    return client.patch(Uri.parse("$baseUrl/profile/theme"),
        body: {"theme" : jsonEncode(body) }, headers: headers);
  }

  Future<http.Response> modifyLanguageRequest(Object body) {
    return client.patch(Uri.parse("$baseUrl/profile/language"),
        body:{"language" : body}, headers: headers);
  }

  // Common utilities
  void updateCookie(Cookie cookie) {
    headers['cookie'] = "${cookie.name}=${cookie.value}";
  }
}
