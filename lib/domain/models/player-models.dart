class Player {
  final String name;
  int score = 0;

  Player(this.name);

  Player.fromJson(json)
      : name = json['name'],
        score = json['score'];

  Map toJson() =>
      {"name": name, "score": score};
}
