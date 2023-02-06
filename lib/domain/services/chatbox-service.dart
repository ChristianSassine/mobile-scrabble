import 'package:mobile/domain/models/chat-models.dart';
import 'package:rxdart/rxdart.dart';

class ChatboxService {
  List<ChatMessage> messages = [];
  final subject = BehaviorSubject<bool>.seeded(true); // We don't need to send the string but it'll do for now

  void submitMessage(String msg){
    messages.add(ChatMessage('????', 'client', msg, DateTime.now()));
    subject.add(true);
  }
}
