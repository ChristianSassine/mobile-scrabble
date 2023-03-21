enum SocketEvents {
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
  UpdateRoomJoinable('updateListOfRooms'),
  PlayerJoinGameAvailable('roomJoin'),
  JoinValidGame('joinValid')
  ;

  const SocketEvents(this.event);

  final String event;
}
