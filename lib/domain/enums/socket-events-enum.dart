enum ChatRoomSocketEvents {
  JoinHomeRoom('joinHomeRoom'),
  UserJoinedRoom('userJoinedRoom'),
  RoomIsFull('roomIsFull'),
  SendHomeMessage('sendMessageHome'),
  BroadCastMessageHome('broadcastMessageHome'),
  LeaveHomeRoom('leaveHomeRoom'),
  userLeftHomeRoom('userLeftHomeRoom'),
  UserConnected('userConnected'),
  usernameTaken('usernameTaken');

  const ChatRoomSocketEvents(this.event);

  final String event;
}

enum RoomSocketEvent {
  CreateWaitingRoom('createGame'),
  JoinWaitingRoom('roomJoin'),
  UpdateWaitingRoom('gameCreatedConfirmation'),
  ExitWaitingRoom('exitWaitingRoom'),
  JoinedValidWaitingRoom('joinValid'),
  UpdateGameRooms('updateListOfRooms'),
  PlayerJoinedWaitingRoom('foundOpponent'),
  ErrorJoining('joiningError'),
  EnterRoomLobby('roomLobby'),
  KickedFromWaitingRoom('kickedFromGameRoom'),
  GameAboutToStart('gameAboutToStart'),
  OpponentLeave('opponentLeave'),
  StartScrabbleGame('startScrabbleGame');

  const RoomSocketEvent(this.event);

  final String event;
}
