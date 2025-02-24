enum Platform {
  pc(6, 'PC'),
  ps5(167, 'PS5'),
  nintendoSwitch(130, 'Switch');

  final int id;
  final String name;

  const Platform(this.id, this.name);
}

class Game {
  final int id;
  final String name;
  final String cover;

  const Game({required this.id, required this.name, required this.cover});

  factory Game.fromJson(Map<String, dynamic> json) {
    final coverUrl =
        json.containsKey("cover")
            ? json['cover']['url'].replaceFirst("//", "https://")
            : "";
    return Game(id: json['id'], name: json['name'], cover: coverUrl);
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
