import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mobile/domain/models/deeplink-info-model.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:mobile/screens/login-screen.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/screens/room-selection-screen.dart';
import 'package:mobile/domain/services/room-service.dart';

class DynamicLinkService {
  final UserService _userService = GetIt.I.get<UserService>();
  final RoomService _roomService = GetIt.I.get<RoomService>();

  Future<String> generateDynamicLink(String roomID, String? password) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse('https://www.scrabble.com/join-game?roomID=$roomID&password=$password'),
        uriPrefix: 'https://flutterscrabble.page.link',
        androidParameters:
            const AndroidParameters(packageName: 'com.example.mobile'));

    final FirebaseDynamicLinks link = FirebaseDynamicLinks.instance;

    final refLink = await link.buildShortLink(parameters);

    return refLink.shortUrl.toString();
  }

  Future<void> handleDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

     dynamicLinks.getInitialLink().then((linkData) {
      final Uri? deepLink = linkData?.link;
      if (deepLink != null) {
        // Handle the deep link here
        handleDeepLink(linkData!);
      }
    });

    // Incoming Links Listener
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        handleDeepLink(dynamicLinkData);
      } else {
        debugPrint("No Current Links");
      }
    });
  }

  Future<void> handleDeepLink(PendingDynamicLinkData dynamicLink) async {
    // Verify if user is logged in
    final isLoggedIn = _userService.user != null;
    final Uri deepLink = dynamicLink.link;
    final String? roomID = deepLink.queryParameters['roomID'];
    final String? password = deepLink.queryParameters['password'];

    if (!isLoggedIn) {
      // Redirect to login page, then redirect to room
      final DeepLinkInfo deepLinkInfo = DeepLinkInfo(isFromDeepLink: true, roomID: roomID, password: password);
      Navigator.of(GetIt.I.get<GlobalKey<NavigatorState>>().currentContext!)
          .push(MaterialPageRoute(
              builder: (context) => LoginScreen(
                    title: FlutterI18n.translate(
                        context, 'menu_screen.sign_up_screen'),
                        deepLinkInfo: deepLinkInfo,
                  )));
    } else {
      Navigator.of(GetIt.I.get<GlobalKey<NavigatorState>>().currentContext!)
          .push(MaterialPageRoute(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _roomService.requestJoinRoom(roomID as String, password);
        });
        return const RoomSelectionScreen();
      }));

      // _roomService.requestJoinRoom(roomID as String);
    }
  }
}
