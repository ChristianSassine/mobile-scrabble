enum ServerError {
  RoomSameUser('roomSameUser'),
  RoomNotAvailable('roomNotAvailable'),
  RoomWrongPassword('roomWrongPassword'),
  NULL(''),
  PasswordChangeSucess('Password changed successfully'),
  PasswordSameError('New password is the same as the old one'),
  PasswordChangeError('An error has occurred while changing the password'),
  UsernameChangeSucess('Username changed successfully'),
  UsernameExistsError('Username is already taken'),
  UsernameChangeError('An error has occurred while changing the username'),
  EmailPasswordSuccess('The forgot password email has successfully been sent'),
  EmailPasswordError(
      'An error has ocurred while sending the forgot password email'),
  ;

  const ServerError(this.error);
  final String error;

  static ServerError fromString(String error) {
    for (ServerError sError in values) {
      if (sError.error == error) return sError;
    }
    return ServerError.NULL;
  }

  @override
  String toString() {
    return error;
  }
}
