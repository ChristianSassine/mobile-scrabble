class HighScore {
  final String _id;
  final String username;
  final String type;
  final int score;
  final int position;

  HighScore(this._id, this.username, this.type, this.score, this.position);

  HighScore.fromJson(json)
      : _id = json['_id'],
        username = json['username'],
        type = json['type'],
        score = json['score'],
        position = json['position'];

  Map toJson() =>
      {
        "_id": _id,
        "username": username,
        "type": type,
        "score" : score,
        "position" : position,
      };
}
