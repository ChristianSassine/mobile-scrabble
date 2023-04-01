import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/components/indicator-widget.dart';
import 'package:mobile/domain/models/user-profile-models.dart';
import 'package:mobile/screens/user-settings-screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  final mockMatches = [
    MatchHistory(true, '19:30 - 19/03/2022'),
    MatchHistory(false, '18:30 - 19/03/2022'),
    MatchHistory(true, '17:30 - 19/03/2022 ')
  ];

  final mockConnections = [
    ConnectionHistory(true, '19:30 - 19/03/2022'),
    ConnectionHistory(false, '18:30 - 19/03/2022'),
    ConnectionHistory(true, '17:30 - 19/03/2022 ')
  ];

  Widget _buildMatchItem(MatchHistory matchHistory) {
    final matchState = FlutterI18n.translate(
        context,
        matchHistory.isVictory
            ? "user_profile.match.defeat"
            : "user_profile.match.defeat");
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
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final mockData = PieChartData(sections: [
      PieChartSectionData(title: "${25}", value: 25, color: Colors.green),
      PieChartSectionData(title: "${75}", value: 75, color: Colors.red),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text("User profile"),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Text("JohnScrabble", style: theme.textTheme.titleLarge),
                    CircleAvatar(
                      radius: size.height * 0.05,
                      child:
                          Icon(Icons.person), // TODO : replace with real image
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const UserSettingsScreen()));
                        },
                        child: Text("Settings")),
                    Divider(),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Statistics",
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              Text("Temps : 4 m/partie"),
                              Text("Parties jouées : 100"),
                              Text("Score moyen par partie : 500"),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Indicator(
                                        color: Colors.green,
                                        text: "Win",
                                        isSquare: false),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Indicator(
                                        color: Colors.red,
                                        text: "Loss",
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
                                  "Histories",
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
                                                child: Text(FlutterI18n.translate(context, "user_profile.matchs.label")),
                                              ),
                                              Tab(
                                                child: Text(FlutterI18n.translate(context, "user_profile.connections.label")),
                                              )
                                            ],
                                          ),
                                          height: 30,
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                ListView(
                                                    children: mockMatches
                                                        .map((matchHistory) =>
                                                            _buildMatchItem(
                                                                matchHistory))
                                                        .toList()),
                                                ListView(
                                                    children: mockConnections
                                                        .map((connectionHistory) =>
                                                            _buildConnectionItem(
                                                                connectionHistory))
                                                        .toList()),
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