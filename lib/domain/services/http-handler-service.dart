import 'package:http/http.dart' as http;

class HttpHandlerService {
  late final http.Client client;
  late final String baseUrl;

  HttpHandlerService(String serverAddress) {
    client = http.Client();
    baseUrl = serverAddress;
  }

  // Auth requests
  signInRequest(Object body){
    return client.post(Uri.parse("${baseUrl}/auth/login"), body: body);
  }

  signUpRequest(Object body){
    return client.post(Uri.parse("${baseUrl}/auth/signUp"), body: body);
  }
}
