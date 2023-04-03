enum ServerError {
  RoomSameUser('roomSameUser'),
  RoomNotAvailable('roomNotAvailable'),
  RoomWrongPassword('roomWrongPassword'),
  NULL(''),
  PasswordChangeSucess('Password changed succesfully'),
  PasswordSameError('New password is the same as the old one'),
  PasswordChangeError('An error has occured while changing the password'),
  UsernameChangeSucess('Username changed succesfully'),
  UsernameExistsError('Username is already taken'),
  UsernameChangeError('An error has occured while changing the username'),
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
