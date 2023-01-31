import 'package:rxdart/rxdart.dart';

class ChatboxService {
  var chat = [];
  final subject = BehaviorSubject<String>(); // We don't need to send the string but it'll do for now

  void addMessage(String msg){
    chat.add(msg);
    subject.add(msg);
  }
}
