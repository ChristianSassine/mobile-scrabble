import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chatroom-widget.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/chat-service.dart';

class SideChatWidget extends StatefulWidget {
  const SideChatWidget({Key? key, this.embedded = false}) : super(key: key);
  final bool embedded;

  @override
  State<SideChatWidget> createState() => _SideChatWidgetState();
}

class _SideChatWidgetState extends State<SideChatWidget> {
  @override
  dispose() {
    debugPrint("SideChatWidgetDisposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Navigator(
        onGenerateRoute: (settings) {
          return CupertinoPageRoute(
              builder: (BuildContext context) =>
                  ChatWidget(embedded: widget.embedded));
        },
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key, required this.embedded}) : super(key: key);
  final bool embedded;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with SingleTickerProviderStateMixin {
  // services
  final _chatService = GetIt.I.get<ChatService>();

  // Tools
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final _joinedSearchBarController = TextEditingController();
  final _availableSearchBarController = TextEditingController();
  final _newRoomCreationController = TextEditingController();
  final _createRoomKey = GlobalKey<FormFieldState>();
  final scaffoldMessangerKey = GlobalKey<ScaffoldMessengerState>();

  // Rooms
  List<ChatRoom> _availableRooms = [];
  List<ChatRoom> _joinedRooms = [];
  List<ChatRoom> _searchedAvailableRooms = [];
  List<ChatRoom> _searchedJoinedRooms = [];

  // Listeners
  late final StreamSubscription _updateRoomsSub;
  late final StreamSubscription _updateNotifsSub;
  late final StreamSubscription _joinRoomSub;
  late final StreamSubscription _errorRoomSub;

  @override
  void initState() {
    super.initState();
    _availableRooms = _chatService.availableRooms;
    _joinedRooms = _chatService.joinedRooms;

    _updateNotifsSub =
        _chatService.notifyUpdatedNotifications.stream.listen((event) {
      setState(() {});
    });

    _updateRoomsSub =
        _chatService.notifyUpdatedChatrooms.stream.listen((event) {
      setState(() {
        _availableRooms = _chatService.availableRooms;
        _joinedRooms = _chatService.joinedRooms;
        _onSearchAvailableRooms(_availableSearchBarController.text);
        _onSearchJoinedRooms(_joinedSearchBarController.text);
      });
    });

    _joinRoomSub = _chatService.notifyJoinRoom.stream.listen((event) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatRoomWidget(
                scaffoldMessagerKey: scaffoldMessangerKey,
              )));
    });

    _errorRoomSub = _chatService.notifyError.stream.listen((error) {
      scaffoldMessangerKey.currentState!.showSnackBar(
          SnackBarFactory.redSnack(FlutterI18n.translate(context, error)));
    });

    if (_chatService.currentRoom != null && !widget.embedded) {
      _chatService.requestJoinRoomSession(_chatService.currentRoom!);
    }
  }

  @override
  dispose() {
    _errorRoomSub.cancel();
    _updateNotifsSub.cancel();
    _joinRoomSub.cancel();
    _updateRoomsSub.cancel();
    super.dispose();
  }

  _onSearchAvailableRooms(String search) {
    _searchedAvailableRooms.clear();
    if (search.isEmpty) {
      setState(() {});
      return;
    }
    for (var room in _availableRooms) {
      if (room.name.contains(search)) _searchedAvailableRooms.add(room);
    }
    setState(() {});
  }

  _onSearchJoinedRooms(String search) {
    _searchedJoinedRooms.clear();
    if (search.isEmpty) {
      setState(() {});
      return;
    }
    for (var room in _joinedRooms) {
      if (room.name.contains(search)) _searchedJoinedRooms.add(room);
    }
    setState(() {});
  }

  AlertDialog _buildRoomCreationDialog() {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "chat.create_room.label")),
      content: IntrinsicHeight(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: _createRoomKey,
                controller: _newRoomCreationController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim() == '') {
                    return FlutterI18n.translate(
                        context, "chat.create_room.error");
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, "chat.create_room.hint"),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (!_createRoomKey.currentState!.validate()) return;
                      Navigator.of(context, rootNavigator: true)
                          .pop(_newRoomCreationController.text);
                      _newRoomCreationController.clear();
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text:
                          "${FlutterI18n.translate(context, "chat.create_room.note_1")}: ",
                      style: theme.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "${FlutterI18n.translate(context, "chat.create_room.note_2")} ",
                      style: theme.textTheme.labelMedium),
                  TextSpan(
                      text: FlutterI18n.translate(
                          context, "chat.create_room.note_3"),
                      style: theme.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          " ${FlutterI18n.translate(context, "chat.create_room.note_4")} ",
                      style: theme.textTheme.labelMedium),
                  TextSpan(
                      text: FlutterI18n.translate(
                          context, "chat.create_room.note_5"),
                      style: theme.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold))
                ]),
              ),
            )
          ],
        ),
      ),
      // actions: [

      // ],
    );
  }

  ListView _buildAvailableRooms() {
    final inSearch = _searchedAvailableRooms.isNotEmpty ||
        _availableSearchBarController.text.isNotEmpty;
    return ListView.builder(
        itemCount:
            inSearch ? _searchedAvailableRooms.length : _availableRooms.length,
        itemBuilder: (context, i) {
          final room =
              inSearch ? _searchedAvailableRooms[i] : _availableRooms[i];

          return Card(
            child: ListTile(
              title: Text(room.name),
              trailing: OutlinedButton(
                child: Text(FlutterI18n.translate(context, "chat.join_label")),
                onPressed: () {
                  _chatService.requestJoinChatRoom(room);
                },
              ),
            ),
          );
        });
  }

  ListView _buildJoinedRooms() {
    final inSearch = _searchedJoinedRooms.isNotEmpty ||
        _joinedSearchBarController.text.isNotEmpty;
    return ListView.builder(
        itemCount: inSearch ? _searchedJoinedRooms.length : _joinedRooms.length,
        itemBuilder: (context, i) {
          final room = inSearch ? _searchedJoinedRooms[i] : _joinedRooms[i];

          return Card(
            child: ListTile(
              title: Text(room.name),
              trailing: OutlinedButton(
                child: _chatService.isRoomUnread(room.name)
                    ? badges.Badge(
                        child: Text(
                            FlutterI18n.translate(context, "chat.join_label")))
                    : Text(FlutterI18n.translate(context, "chat.join_label")),
                onPressed: () {
                  _chatService.requestJoinRoomSession(room);
                },
              ),
            ),
          );
        });
  }

  Widget _buildSearchBar(BuildContext context, bool inAvailableRooms) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.search),
            title: TextField(
              controller: inAvailableRooms
                  ? _availableSearchBarController
                  : _joinedSearchBarController,
              decoration: InputDecoration(
                  hintText: FlutterI18n.translate(context, "chat.search_label"),
                  border: InputBorder.none),
              onChanged: (search) {
                inAvailableRooms
                    ? _onSearchAvailableRooms(search)
                    : _onSearchJoinedRooms(search);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                if (inAvailableRooms) {
                  _availableSearchBarController.clear();
                  _onSearchAvailableRooms("");
                  return;
                }
                _joinedSearchBarController.clear();
                _onSearchJoinedRooms("");
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessangerKey,
      child: Scaffold(
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              // Navigation buttons (Header)
              height: 30,
              child: TabBar(
                // TODO : Customize colors
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.green,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                controller: _tabController,
                tabs: [
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(FlutterI18n.translate(
                          context, "chat.joined_rooms_label")),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(FlutterI18n.translate(
                          context, "chat.available_rooms_label")),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              child: Container(
            // Content of each tab (bodies)
            child: TabBarView(controller: _tabController, children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  _buildRoomCreationDialog()).then(
                              (newRoomName) => newRoomName != null
                                  ? _chatService.createChatRoom(newRoomName)
                                  : null);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            Text(FlutterI18n.translate(
                                context, "chat.create_room_label")),
                          ],
                        )),
                  ),
                  _buildSearchBar(context, false),
                  Expanded(child: _buildJoinedRooms()),
                ],
              ),
              Column(
                children: [
                  _buildSearchBar(context, true),
                  Expanded(child: _buildAvailableRooms()),
                ],
              )
            ]),
          )),
        ]),
      ),
    );
  }
}
