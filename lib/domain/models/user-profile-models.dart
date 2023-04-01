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
