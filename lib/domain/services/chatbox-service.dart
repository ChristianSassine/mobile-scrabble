import 'package:mobile/domain/models/chat-models.dart';
import 'package:rxdart/rxdart.dart';

class ChatboxService {
  List<ChatMessage> msgs = [ChatMessage('username', 'type', 'message', DateTime.now())];
  final subject = BehaviorSubject<bool>.seeded(true); // We don't need to send the string but it'll do for now

  // void addMessage(String msg){
  //   msgs.add(msg);
  //   subject.add(msg);
  // }
}
