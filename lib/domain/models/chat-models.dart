import 'package:rxdart/rxdart.dart';

class ChatRoom {
  final String name;
  final String? creatorId;
  final bool isDeletable;

  ChatRoom.fromJson(json)
      : name = json['name'],
        creatorId = json['creatorId'],
        isDeletable = json['isDeletable'];
}

class ChatMessage {
  final String userId;
  final String message;
  final String date;

  ChatMessage(this.userId, this.message, this.date);

  ChatMessage.fromJson(json)
      : userId = json['userId'],
        message = json['message'],
        date = json['date'];


  Map toJson() => {
        "userId": userId,
        "message": message,
        "date": date
      };
}

enum MessageType {
  CLIENT("client"),
  SYSTEM("system"),
  COMMAND("command");

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
