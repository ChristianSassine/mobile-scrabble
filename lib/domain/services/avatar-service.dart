import 'package:http/http.dart' as http;

class AvatarService {
  static const _serverURL = 'http://localhost:3000/image';

  Future<void> defaultAvatars() async {
    var response = await http.get(Uri.parse('$_serverURL/default-pictures'));
    if (response.statusCode == 200) {
      print('Number of books about http: ${response.body}.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
