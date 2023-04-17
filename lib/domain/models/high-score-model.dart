class HighScore {
  final String username;
  final int ranking;

  HighScore(this.username, this.ranking);

  HighScore.fromJson(json)
      : username = json['username'],
        ranking = json['ranking'];

  Map toJson() => {
        "username": username,
        "ranking": ranking,
      };
}
