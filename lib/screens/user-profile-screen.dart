import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/indicator-widget.dart';
import 'package:mobile/domain/extensions/string-extensions.dart';
import 'package:mobile/domain/models/user-profile-models.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/user-settings-screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _userService = GetIt.I.get<UserService>();
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  Widget _buildMatchItem(MatchHistory matchHistory) {
    final matchState = FlutterI18n.translate(
        context,
        matchHistory.isVictory
            ? "user_profile.matchs.victory"
            : "user_profile.matchs.defeat");
    return Card(
      child: ListTile(
        title: Text(
          matchState,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: matchHistory.isVictory ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
        trailing: Text(matchHistory.timestamp),
      ),
    );
  }

  Widget _buildConnectionItem(ConnectionHistory connectionHistory) {
    final matchState = FlutterI18n.translate(
        context,
        connectionHistory.isConnect
            ? "user_profile.connections.connect"
            : "user_profile.connections.disconnect");
    return Card(
      child: ListTile(
        title: Text(
          matchState,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Text(connectionHistory.timestamp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userService.fetchInformation();

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isUser = _userService.user?.profilePicture != null;

    final mockData = PieChartData(sections: [
      PieChartSectionData(title: "${25}", value: 25, color: Colors.green),
      PieChartSectionData(title: "${75}", value: 75, color: Colors.red),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "user_profile.title")),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Text(_userService.user!.username.capitalize(),
                        style: theme.textTheme.titleLarge),
                    CircleAvatar(
                      radius: size.height * 0.05,
                      backgroundImage: isUser
                          ? NetworkImage(
                              _userService.user!.profilePicture!.key!)
                          : null,
                      child: isUser
                          ? null
                          : const Icon(
                              Icons.person), // TODO : replace with real image
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "Score : ", style: theme.textTheme.titleMedium),
                      TextSpan(
                          text: "49992",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold))
                    ])),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      const UserSettingsScreen()))
                              .then((value) => setState(() {}));
                        },
                        child: Text(FlutterI18n.translate(
                            context, "user_profile.settings_button"))),
                    Divider(),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  FlutterI18n.translate(
                                      context, "user_profile.statistics.label"),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text:
                                        "${FlutterI18n.translate(context, "user_profile.statistics.avg_time")} : ",
                                    style: theme.textTheme.bodyMedium),
                                TextSpan(
                                    text: "4",
                                    style: theme.textTheme.bodyLarge!
                                        .copyWith(fontWeight: FontWeight.bold))
                              ])),
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text:
                                        "${FlutterI18n.translate(context, "user_profile.statistics.avg_score")} : ",
                                    style: theme.textTheme.bodyMedium),
                                TextSpan(
                                    text: "500",
                                    style: theme.textTheme.bodyLarge!
                                        .copyWith(fontWeight: FontWeight.bold))
                              ])),
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text:
                                        "${FlutterI18n.translate(context, "user_profile.statistics.cnt_games")} : ",
                                    style: theme.textTheme.bodyMedium),
                                TextSpan(
                                    text: "100",
                                    style: theme.textTheme.bodyLarge!
                                        .copyWith(fontWeight: FontWeight.bold))
                              ])),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Indicator(
                                        color: Colors.green,
                                        text: FlutterI18n.translate(context,
                                            "user_profile.statistics.win_indicator"),
                                        isSquare: false),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Indicator(
                                        color: Colors.red,
                                        text: FlutterI18n.translate(context,
                                            "user_profile.statistics.loss_indicator"),
                                        isSquare: false),
                                  )
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: size.width * 0.35,
                                    child: PieChart(mockData),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const VerticalDivider(),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  FlutterI18n.translate(
                                      context, "user_profile.histories_label"),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.backgroundColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    width: size.width * 0.35,
                                    height: size.height * 0.55,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 30,
                                          child: TabBar(
                                            indicator: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                25.0,
                                              ),
                                              color: Colors.green,
                                            ),
                                            labelColor: Colors.white,
                                            unselectedLabelColor: Colors.black,
                                            controller: _tabController,
                                            tabs: [
                                              Tab(
                                                child: Text(FlutterI18n.translate(
                                                    context,
                                                    "user_profile.matchs.label")),
                                              ),
                                              Tab(
                                                child: Text(FlutterI18n.translate(
                                                    context,
                                                    "user_profile.connections.label")),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                FutureBuilder(
                                                    future: _userService
                                                        .getMatches(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return ListView(
                                                            children: snapshot
                                                                .data!
                                                                .map((matchHistory) =>
                                                                    _buildMatchItem(
                                                                        matchHistory))
                                                                .toList());
                                                      }
                                                      return Container(
                                                          width: 100,
                                                          height: 100,
                                                          child:
                                                              CircularProgressIndicator());
                                                    }),
                                                FutureBuilder(
                                                    future: _userService
                                                        .getConnections(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return ListView(
                                                            children: snapshot
                                                                .data!
                                                                .map((connectionHistory) =>
                                                                    _buildConnectionItem(
                                                                        connectionHistory))
                                                                .toList());
                                                      }
                                                      return Container(
                                                          width: 100,
                                                          height: 100,
                                                          child:
                                                              CircularProgressIndicator());
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
