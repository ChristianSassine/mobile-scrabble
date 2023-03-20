enum RoomSocketEvents {
  JoinHomeRoom('joinHomeRoom'),
  UserJoinedRoom('userJoinedRoom'),
  RoomIsFull('roomIsFull'),
  SendHomeMessage('sendMessageHome'),
  BroadCastMessageHome('broadcastMessageHome'),
  LeaveHomeRoom('leaveHomeRoom'),
  userLeftHomeRoom('userLeftHomeRoom'),
  UserConnected('userConnected'),
  usernameTaken('usernameTaken'),
  RoomLobby('roomLobby'),
  UpdateRoomJoinable('updateListOfRooms');

  const RoomSocketEvents(this.event);

  final String event;
}
