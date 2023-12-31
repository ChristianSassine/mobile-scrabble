enum ChatRoomSocketEvents {
  SendMessage('sendMessage'),
  CreateChatRoom('createChatRoom'),
  DeleteChatRoom('deleteChatRoom'),
  JoinChatRoom('joinChatRoom'),
  LeaveChatRoom('leaveChatRoom'),
  JoinChatRoomSession('joinChatRoomSession'),
  LeaveChatRoomSession('leaveChatRoomSession'),
  GetAllChatRooms('getAllChatRooms'),
  CreateChatRoomError('createChatRoomError'),
  DeleteChatRoomNotFoundError('deleteChatRoomNotFoundError'),
  DeleteChatNotCreatorError('deleteChatNotCreatorError'),
  JoinChatRoomNotFoundError('joinChatRoomNotFoundError'),
  LeaveChatRoomNotFoundError('leaveChatRoomNotFoundError'),
  JoinChatRoomSessionNotFoundError('joinChatRoomSessionNotFoundError'),
  LeaveChatRoomSessionNotFoundError('leaveChatRoomSessionNotFoundError'),
  SendMessageError('sendMessageError');

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
  AbandonGame('AbandonGame'),
  ReserveCommand('reserveCommand'),
  ClueCommand('clueCommand'),
  NextTurn('nextTurn'),
  GameEnded('endGame'),
  PlacementSuccess('placementSuccess'),
  PlacementFailure('placementFailure'),
  LetterReserveUpdated("letterReserveUpdated"),
  JoinAsObserver('joinAsObserver'),
  CannotReplaceBot('cannotReplaceBot'),
  SendDrag('sd'),
  DragEvent('de'),
  LetterPlaced('lp'),
  LetterTaken('lt');

  const GameSocketEvent(this.event);

  final String event;
}

enum ConnectionEvent {
  SuccessfulConnection('SuccessfulConnection'),
  UserAlreadyConnected('UserAlreadyConnected');

  const ConnectionEvent(this.event);

  final String event;
}
