import 'package:rxdart/rxdart.dart';

class ChatMessage {
  final String username;
  final String type;
  final String message;
  final String timeStamp;

  ChatMessage(this.username, this.type, this.message, this.timeStamp);

  ChatMessage.fromJson(json)
      : username = json['username'],
        type = json['type'],
        message = json['message'],
        timeStamp = json['timeStamp'];


  Map toJson() => {
        "username": username,
        "type": type,
        "message": message,
        "timeStamp": timeStamp
      };
}

enum MessageType {
  CLIENT("CLIENT"),
  SYSTEM("SYSTEM"),
  COMMAND("COMMAND");

  const MessageType(this.value);

  final String value;
}

class ChatBox {
  List<ChatMessage> messages = [];
  final subject = BehaviorSubject<bool>.seeded(
      true); // We don't need to send the string but it'll do for now

  void addMessage(ChatMessage chatMessage) {
    messages.add(chatMessage);
    subject.add(true);
  }
}
