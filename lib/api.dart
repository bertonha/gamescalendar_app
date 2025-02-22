import 'dart:convert';
import 'package:http/http.dart' as http;
import 'game.dart';

const clientId = String.fromEnvironment("CLIENT_ID");
const token = String.fromEnvironment("TOKEN");

Future<List<GameRelease>> fetchReleaseGames(
  List<Platform> platforms,
  DateTime start,
  DateTime end,
) async {
  if (clientId.isEmpty) {
    throw Exception("CLIENT_ID not set");
  }
  if (token.isEmpty) {
    throw Exception("TOKEN not set");
  }

  if (platforms.isEmpty) {
    return [];
  }

  var epochStart = start.millisecondsSinceEpoch ~/ 1000;
  var epochEnd = end.millisecondsSinceEpoch ~/ 1000;

  var formatedPlatforms = platforms
      .map((e) => e.id.toString())
      .toList()
      .join(",");

  final response = await http.post(
    Uri.parse('https://api.igdb.com/v4/release_dates'),
    headers: {"Client-ID": clientId, "Authorization": "Bearer $token"},
    body: """
        fields game.name,game.cover.url,platform,date;
        where
        date > $epochStart
        & date < $epochEnd
        & platform = ($formatedPlatforms);
        sort date asc;
        limit 200;
    """,
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
