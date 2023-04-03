import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/high-score-model.dart';
import 'package:mobile/domain/services/http-handler-service.dart';

class HighScores extends StatelessWidget {
  HighScores({
    Key? key,
  }) : super(key: key);

  final HttpHandlerService _httpService = GetIt.I.get<HttpHandlerService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: _httpService.fetchHighScoresRequest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(
                  FlutterI18n.translate(context, "menu_screen.high_scores.error"))); // TODO: Translate
              return const SizedBox();
            }
            return IntrinsicHeight(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      FlutterI18n.translate(context, "menu_screen.high_scores.title"),
                      style: theme.textTheme.displayMedium,
                    ),
                    DataTable(
                        columnSpacing: size.width * 0.2,
                        columns: [
                          DataColumn(
                              label: Text(
                            FlutterI18n.translate(context, "menu_screen.high_scores.label_score"),
                            textAlign: TextAlign.center,
                          )),
                          DataColumn(
                              label: Text(
                                FlutterI18n.translate(context, "menu_screen.high_scores.label_player"),
                            textAlign: TextAlign.center,
                          )),
                        ],
                        rows: (jsonDecode(snapshot.data!.body) as List<dynamic>)
                            .map((e) => HighScore.fromJson(e)) // Transform data to models
                            .map(
                              (e) => DataRow(cells: [
                                DataCell(Text(
                                  "${e.score}",
                                  textAlign: TextAlign.center,
                                )),
                                DataCell(Text(e.username))
                              ]),
                            ) // Transform models to DataRows
                            .toList())
                  ],
                ),
              ),
            );
          }
          return const SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator());
        },
      ),
    );
  }
}
