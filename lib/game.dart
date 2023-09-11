enum Platform {
  pc(6, 'PC', 'PC'),
  ps4(48, 'PlayStation 4', 'PS4'),
  ps5(167, 'PlayStation 5', 'PS5'),
  nintendoSwitch(130, 'Nintendo Switch', 'Switch');

  final int id;
  final String desc;
  final String abreviation;

  const Platform(this.id, this.desc, this.abreviation);
}

class Game {
  final int id;
  final String name;
  final String cover;

  const Game({
    required this.id,
    required this.name,
    required this.cover,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      cover: json.containsKey("cover")
          ? json['cover']['url'].replaceFirst("//", "https://")
          : "",
    );
  }
}

class GameRelease {
  final Game game;
  final Platform platform;
  final int date;

  const GameRelease({
    required this.game,
    required this.platform,
    required this.date,
  });

  factory GameRelease.fromJson(Map<String, dynamic> json) {
    return GameRelease(
      game: Game.fromJson(json['game']),
      platform: Platform.values.firstWhere((x) => x.id == json['platform']),
      date: json['date'],
    );
  }
}
