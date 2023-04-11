class DeepLinkInfo {
  final bool isFromDeepLink;
  final String? roomID;
  final String? password;

  DeepLinkInfo(
      {required this.isFromDeepLink,
      this.roomID,
      this.password,
      });
}