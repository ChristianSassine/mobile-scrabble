enum RoomSocketEvents {
  JoinHomeRoom('joinHomeRoom'),
  UserJoinedRoom('userJoinedRoom'),
  RoomIsFull('roomIsFull'),
  SendHomeMessage('sendMessageHome'),
  BroadCastMessageHome('broadcastMessageHome'),
  LeaveHomeRoom('leaveHomeRoom'),
  userLeftHomeRoom('userLeftHomeRoom'),
  usernameTaken('usernameTaken');

  const RoomSocketEvents(this.event);

  final String event;
}
