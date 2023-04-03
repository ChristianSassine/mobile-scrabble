enum ChatRoomSocketEvents {
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
  JoinValidGame('joinValid'),
  ExitWaitingRoom('exitWaitingRoom');

  const ChatRoomSocketEvents(this.event);

  final String event;
}

enum RoomSocketEvent {
  CreateWaitingRoom('createGame'),
  JoinWaitingRoom('roomJoin'),
  UpdateWaitingRoom('gameCreatedConfirmation'),
  ExitWaitingRoom('exitWaitingRoom'),
  UpdateGameRooms('updateListOfRooms'),
  JoinedValidWaitingRoom('joinValid'),
  PlayerJoinedWaitingRoom('foundOpponent'),
  ErrorJoining('joiningError'),
  EnterRoomLobby('roomLobby'),
  KickedFromWaitingRoom('kickedFromGameRoom'),
  GameAboutToStart('gameAboutToStart'),
  OpponentLeave('opponentLeave'),
  StartScrabbleGame('startScrabbleGame'),
  PublicViewUpdate('updateClientView');

  const RoomSocketEvent(this.event);

  final String event;
}

enum GameSocketEvent {
  PlaceWordCommand('placeWord'),
  Exchange('ExchangeLetters'),
  Skip('skip'),
  QuitGame('quitGame'),
  ReserveCommand('reserveCommand'),
  ClueCommand('clueCommand'),
  NextTurn('nextTurn'),
  GameEnded('endGame');

  const GameSocketEvent(this.event);

  final String event;
}
