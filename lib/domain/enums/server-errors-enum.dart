enum ServerError {
  RoomSameUser('roomSameUser'),
  RoomNotAvailable('roomNotAvailable'),
  RoomWrongPassword('roomWrongPassword'),
  NULL('')
  ;

  const ServerError(this.error);
  final String error;

  static ServerError fromString(String error){
    for (ServerError sError in values){
      if (sError.error == error) return sError;
    }
    return ServerError.NULL;
  }

  @override
  String toString() {
    return error;
  }
}
