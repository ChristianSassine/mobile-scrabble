import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/components/indicator-widget.dart';
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

  final mockData = PieChartData(sections: [
    PieChartSectionData(title: "${75}", value: 75, color: Colors.red),
    PieChartSectionData(title: "${25}", value: 25, color: Colors.green)
  ]);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("User profile"),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicWidth(
              child: Column(
                children: [
                  Text("JohnScrabble", style: theme.textTheme.titleLarge),
                  CircleAvatar(
                    radius: size.height * 0.05,
                    child: Icon(Icons.person), // TODO : replace with real image
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
                            builder: (context) => const UserSettingsScreen()));
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                      25.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: TabBar(
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
                                              child: Text("Matches"),
                                            ),
                                            Tab(
                                              child: Text("Connections"),
                                            )
                                          ],
                                        ),
                                        height: 30,
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            Text('Match histories'),
                                            Text('Connection histories'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: size.width * 0.35,
                                  height: size.height * 0.55),
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
    );
  }
}
