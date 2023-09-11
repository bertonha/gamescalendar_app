import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'game.dart';
import 'api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Game Release Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var platforms = <Platform>[];
  late Future<List<GameRelease>> futureGameReleases;
  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    start = DateTime(2023, 9, 1);
    end = DateTime(start.year, start.month + 1, start.day);
    futureGameReleases = fetchReleaseGames([], start, end);
  }

  void _togglePlatform(Platform plastform) {
    setState(() {
      if (platforms.contains(plastform)) {
        platforms.remove(plastform);
      } else {
        platforms.add(plastform);
      }

      futureGameReleases = fetchReleaseGames(platforms, start, end);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          PlatformSelection(
              platforms: platforms, myVoidCallback: _togglePlatform),
          GameReleaseList(futureGameReleases: futureGameReleases),
        ],
      ),
    );
  }
}

class PlatformSelection extends StatelessWidget {
  const PlatformSelection({
    super.key,
    required this.platforms,
    required this.myVoidCallback,
  });

  final List<Platform> platforms;
  final ValueChanged<Platform> myVoidCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var item in Platform.values)
          CheckboxListTile(
            title: Text(item.desc),
            value: platforms.contains(item),
            onChanged: (bool? value) {
              myVoidCallback(item);
            },
          ),
      ],
    );
  }
}

class GameReleaseList extends StatelessWidget {
  const GameReleaseList({
    super.key,
    required this.futureGameReleases,
  });

  final Future<List<GameRelease>> futureGameReleases;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameRelease>>(
      future: futureGameReleases,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Text('No data');
          }

          return Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('Game Releases')),
                ),
                for (var item in snapshot.data!) GameReleaseWidget(item: item),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}',
              style: const TextStyle(color: Colors.red));
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class GameReleaseWidget extends StatelessWidget {
  const GameReleaseWidget({
    super.key,
    required this.item,
  });

  final GameRelease item;

  @override
  Widget build(BuildContext context) {
    var formattedDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(item.date * 1000));

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          item.game.cover.isNotEmpty
              ? Image.network(item.game.cover)
              : const Placeholder(fallbackWidth: 90, fallbackHeight: 90),
          Expanded(
            child: Column(
              children: [
                Text(
                  item.game.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(formattedDate),
              ],
            ),
          ),
          Text(item.platform.abreviation),
        ],
      ),
    );
  }
}
