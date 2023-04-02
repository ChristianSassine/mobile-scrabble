enum HistoryAction {
  Connection('connection'),
  Logout('logout'),
  Game('game'),
  NULL('');

  const HistoryAction(this.value);
  final value;

  static HistoryAction fromString(String historyEvent) {
    for (HistoryAction history in values) {
      if (history.value == historyEvent) return history;
    }
    return HistoryAction.NULL;
  }
}

// TODO: change if model it isn't the correct interface
class MatchHistory {
  final bool isVictory;
  final String timestamp;

  MatchHistory(this.isVictory, this.timestamp);

  MatchHistory.fromJson(json)
      : isVictory = json['isVictory'],
        timestamp = json['timestamp'];
}

// TODO: change if model it isn't the correct interface
class ConnectionHistory {
  final bool isConnect;
  final String timestamp;

  ConnectionHistory(this.isConnect, this.timestamp);

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
        gameWon = json['gameWon']
  ;
}
