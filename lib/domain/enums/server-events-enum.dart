enum ServerEvents {
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

  const ServerEvents(this.error);
  final String error;

  static ServerEvents fromString(String error) {
    for (ServerEvents sError in values) {
      if (sError.error == error) return sError;
    }
    return ServerEvents.NULL;
  }

  @override
  String toString() {
    return error;
  }
}
