import 'dart:convert';
import 'package:http/http.dart' as http;
import 'game.dart';

Future<List<GameRelease>> fetchReleaseGames(
  List<Platform> platforms,
  DateTime start,
  DateTime end,
) async {
  if (platforms.isEmpty) {
    return [];
  }

  var formatedPlatforms = platforms.map((e) => e.name).toList();

  final response = await http.post(
    Uri.parse('https://gamescalendar-726749962824.europe-southwest1.run.app'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      "start_date": start.toUtc().toIso8601String(),
      "end_date": end.toUtc().toIso8601String(),
      "platforms": formatedPlatforms,
    }),
  );

  if (response.statusCode == 200) {
    List<GameRelease> games = [];
    for (var item in jsonDecode(response.body)) {
      games.add(GameRelease.fromJson(item));
    }
    return games;
  } else {
    throw Exception('Failed to load games releases: ${response.body}');
  }
}
