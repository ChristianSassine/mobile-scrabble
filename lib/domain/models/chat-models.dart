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

class UserChatRoom {
  final String username;
  final String imageUrl;

  UserChatRoom.fromJson(json)
      : username = json['username'],
        imageUrl = json['imageUrl'];
}

class ChatRoomState {
  final String name;
  final bool notified;

  ChatRoomState.fromJson(json)
      : name = json['name'],
        notified = json['notified'];
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

  Map toJson() => {"userId": userId, "message": message, "date": date};
}

class SentMessage {
  final String chatRoomName;
  final String msg;

  SentMessage(this.chatRoomName, this.msg);

  SentMessage.fromJson(json)
      : chatRoomName = json['chatRoomName'],
        msg = json['msg'];

  Map toJson() => {"chatRoomName": chatRoomName, "msg": msg};
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
