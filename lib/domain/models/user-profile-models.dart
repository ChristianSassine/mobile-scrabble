enum HistoryAction {
  Connection('connection'),
  Logout('logout'),
  Game('game'),
  Null('');

  const HistoryAction(this.value);

  final value;

  static HistoryAction fromString(String historyEvent) {
    for (HistoryAction history in values) {
      if (history.value == historyEvent) return history;
    }
    return HistoryAction.Null;
  }
}

class MatchHistory {
  final bool isVictory;
  final String timestamp;

  MatchHistory(this.isVictory, this.timestamp);

  MatchHistory.fromEvent(HistoryEvent event)
      : isVictory = event.gameWon!,
        timestamp = event.date;

  MatchHistory.fromJson(json)
      : isVictory = json['isVictory'],
        timestamp = json['timestamp'];
}

class ConnectionHistory {
  final bool isConnect;
  final String timestamp;

  ConnectionHistory(this.isConnect, this.timestamp);

  ConnectionHistory.fromEvent(HistoryEvent event)
      : isConnect = event.event == HistoryAction.Connection,
        timestamp = event.date;

  ConnectionHistory.fromJson(json)
      : isConnect = json['isConnect'],
        timestamp = json['timestamp'];
}

class HistoryEvent {
  final HistoryAction event;
  final String date;
  final bool? gameWon;

  HistoryEvent(this.event, this.date, {this.gameWon});

  HistoryEvent.fromJson(json)
      : event = HistoryAction.fromString(json['event']),
        date = json['date'],
        gameWon = json['gameWon'];
}

class UserStats {
  final int loss;
  final int win;
  final int gameCount;
  final int totalGameScore;
  final double averageGameScore;
  final String averageGameTime;

  UserStats(this.gameCount, this.loss, this.win, this.totalGameScore,
      this.averageGameScore, this.averageGameTime);

  UserStats.fromJson(json)
      : loss = json['loss'],
        win = json['win'],
        gameCount = json['gameCount'],
        totalGameScore = json['totalGameScore'],
        averageGameScore = json['averageGameScore'] is int
            ? json['averageGameScore'].toDouble()
            : json['averageGameScore'],
        averageGameTime = (json['averageGameTime'] as String).isNotEmpty
            ? json['averageGameTime']
            : "0 min";
}
