import 'package:rxdart/rxdart.dart';

class ChatboxService {
  var msgs = ["Entered the chat..."];
  final subject = BehaviorSubject<String>.seeded('testing'); // We don't need to send the string but it'll do for now

  ChatboxService(){
    subject.add("2");
  }

  void addMessage(String msg){
    msgs.add(msg);
    subject.add(msg);
  }
}
