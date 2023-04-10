import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chatroom-widget.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/chat-service.dart';

class SideChatWidget extends StatefulWidget {
  const SideChatWidget({Key? key}) : super(key: key);

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
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
            builder: (BuildContext context) => const ChatWidget());
      },
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with SingleTickerProviderStateMixin {
  final _chatService = GetIt.I.get<ChatService>();

  // Tools
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final _searchBarController = TextEditingController();
  final _newRoomCreationController = TextEditingController();

  // Rooms
  List<ChatRoom> _availableRooms = [];
  List<ChatRoom> _joinedRooms = [];
  List<ChatRoom> _searchedAvailableRooms = [];

  // Listeners
  late final StreamSubscription _updateRoomsSub;
  late final StreamSubscription _joinRoomSub;

  @override
  void initState() {
    super.initState();
    _availableRooms = _chatService.availableRooms;
    _joinedRooms = _chatService.joinedRooms;

    _updateRoomsSub =
        _chatService.notifyUpdatedChatrooms.stream.listen((event) {
      setState(() {
        _availableRooms = _chatService.availableRooms;
        _joinedRooms = _chatService.joinedRooms;
      });
    });

    _joinRoomSub = _chatService.notifyJoinRoom.stream.listen((event) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ChatRoomWidget()));
    });

    if (_chatService.currentRoom != null) {
      _chatService.requestJoinRoomSession(_chatService.currentRoom!);
    }
  }

  @override
  dispose() {
    _joinRoomSub.cancel();
    _updateRoomsSub.cancel();
    super.dispose();
  }

  _onSearchRooms(String search) {
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

  AlertDialog _buildRoomCreationDialog() {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "chat.create_room_dialog_label")),
      content: TextFormField(
        controller: _newRoomCreationController,
        validator: null, // TODO: Add validation (empty room string)
        decoration: InputDecoration(
          hintText:
              FlutterI18n.translate(context, "chat.create_room_name_label"),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop(_newRoomCreationController.text);
              _newRoomCreationController.clear();
            },
          ),
        ),
      ),
    );
  }

  ListView _buildAvailableRooms() {
    if (_searchedAvailableRooms.isNotEmpty ||
        _searchBarController.text.isNotEmpty) {
      return ListView.builder(
          itemCount: _searchedAvailableRooms.length,
          itemBuilder: (context, i) {
            final room = _searchedAvailableRooms[i];

            return Card(
              child: ListTile(
                title: Text(room.name),
                trailing: OutlinedButton(
                  child: Text('JOIN'),
                  onPressed: () {
                    _chatService.requestJoinChatRoom(room.name);
                  },
                ),
              ),
            );
          });
    }
    return ListView.builder(
        itemCount: _availableRooms.length,
        itemBuilder: (context, i) {
          final room = _availableRooms[i];

          return Card(
            child: ListTile(
              title: Text(room.name),
              trailing: OutlinedButton(
                child: Text('JOIN'),
                onPressed: () {
                  _chatService.requestJoinChatRoom(room.name);
                },
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
                child: Text("Joined Rooms"),
              ),
              Tab(
                child: Text("Available Rooms"),
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
                              builder: (context) => _buildRoomCreationDialog())
                          .then((newRoomName) => newRoomName != null
                              ? _chatService.createChatRoom(newRoomName)
                              : null);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Create a room"), Icon(Icons.add)],
                    )),
              ),
              Expanded(
                child: ListView(
                    children: _joinedRooms
                        .map((room) => Card(
                              child: ListTile(
                                title: Text(room.name),
                                trailing: OutlinedButton(
                                  child: badges.Badge(child: Text('JOIN')),
                                  onPressed: () {
                                    _chatService.requestJoinRoomSession(room);
                                  },
                                ),
                              ),
                            ))
                        .toList()),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.search),
                      title: TextField(
                        controller: _searchBarController,
                        decoration: InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                        onChanged: (search) {
                          _onSearchRooms(search);
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          _searchBarController.clear();
                          _onSearchRooms("");
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildAvailableRooms()),
            ],
          )
        ]),
      )),
    ]);
  }
}
