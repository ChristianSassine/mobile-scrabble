import 'package:flutter/material.dart';
import 'package:mobile/components/chatroom-widget.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({this.inChat = false, Key? key}) : super(key: key);
  final bool inChat;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final _searchBarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.inChat){
      Future(() {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const ChatRoomWidget()))
            .then((value) => setState(() {}));
      });
    }
  }

  final _availableRooms = ["a", "b", "c", "ROOM 1"];
  final _searchedAvailableRooms = [];

  _onSearchRooms(String search) {
    _searchedAvailableRooms.clear();
    if (search.isEmpty) {
      setState(() {});
      return;
    }
    for (var room in _availableRooms) {
      if (room.contains(search)) _searchedAvailableRooms.add(room);
    }
    setState(() {});
  }

  ListView _buildAvailableRooms() {
    if (_searchedAvailableRooms.isNotEmpty ||
        _searchBarController.text.isNotEmpty) {
      return ListView.builder(
          itemCount: _searchedAvailableRooms.length,
          itemBuilder: (context, i) {
            return Card(
              child: ListTile(
                title: Text(_searchedAvailableRooms[i]),
                trailing: OutlinedButton(
                  child: Text('JOIN'),
                  onPressed: () {},
                ),
              ),
            );
          });
    }
    return ListView.builder(
        itemCount: _availableRooms.length,
        itemBuilder: (context, i) {
          return Card(
            child: ListTile(
              title: Text(_availableRooms[i]),
              trailing: OutlinedButton(
                child: Text('JOIN'),
                onPressed: () {},
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
          ListView(
            children: [
              Card(
                child: ListTile(
                  title: Text("Room Name"),
                  trailing: OutlinedButton(
                    child: Text('JOIN'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatRoomWidget()));
                    },
                  ),
                ),
              )
            ],
          ),
          Column(
            children: [
              Container(
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Card(
                    child: new ListTile(
                      leading: new Icon(Icons.search),
                      title: new TextField(
                        controller: _searchBarController,
                        decoration: new InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                        onChanged: (search) {
                          _onSearchRooms(search);
                        },
                      ),
                      trailing: new IconButton(
                        icon: new Icon(Icons.cancel),
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
