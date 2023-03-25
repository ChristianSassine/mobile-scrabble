import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class HttpHandlerService {
  late final http.Client client;
  late final String baseUrl;
  final dio = Dio();

  HttpHandlerService(String serverAddress) {
    client = http.Client();
    baseUrl = serverAddress;
  }

  // Auth requests
  Future<http.Response> signInRequest(Object body) {
    return client.post(Uri.parse("${baseUrl}/auth/login"), body: body);
  }

  Future<http.Response> signUpRequest(Object body) {
    return client.post(Uri.parse("${baseUrl}/auth/signUp"), body: body);
  }

  // Profile Avatar requests
  Future<http.Response> getDefaultAvatarsRequest() {
    return client.get(
      Uri.parse("${baseUrl}/image/default-pictures"),
    );
  }

  Future<Response> sendAvatarRequest(
      File image, String key) async {
    // final request = http.MultipartRequest(
    //     "POST", Uri.parse("${baseUrl}/image/profile-picture"));
    //
    // request.headers['Content-Type'] = 'multipart/form-data';

    final imageFile = await MultipartFile.fromFile(image.path, contentType: MediaType("image", "*"));
    final imageKey = MultipartFile.fromString(key, contentType: MediaType("text", "html"));

    // request.files.add(imageKey);
    // request.files.add(imageFile);
    // final response = await request.send();
    final formData = FormData();

    formData.files.addAll([MapEntry('data', imageFile), MapEntry('imageKey', imageKey)]);
    return dio.post("$baseUrl/image/profile-picture", data: formData);
  }

  Future<http.Response> fetchHighScoresRequest() {
    return client.get(Uri.parse("${baseUrl}/highScore/classique"));
  }
}
