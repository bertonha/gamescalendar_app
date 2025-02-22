import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api.dart';
import '../game.dart';

class GameCalendar extends StatefulWidget {
  const GameCalendar({super.key, required this.title});

  final String title;

  @override
  State<GameCalendar> createState() => _GameCalendarState();
}

class _GameCalendarState extends State<GameCalendar> {
  var platforms = <Platform>[Platform.ps5];
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    if (startDate.month == 12) {
      endDate = DateTime(now.year + 1, 1, 1);
    } else {
      endDate = DateTime(now.year, now.month + 1, 1);
    }
  }

  void _togglePlatform(Platform platform) {
    setState(() {
      if (platforms.contains(platform)) {
        platforms.remove(platform);
      } else {
        platforms.add(platform);
      }
    });
  }

  void _setDataRange(DateTime newStart, DateTime newEnd) {
    if (newStart.isAfter(newEnd)) {
      newEnd = newStart.add(const Duration(days: 1));
    }
    setState(() {
      startDate = newStart;
      endDate = newEnd;
    });
  }

  void _pickStartDate() {
    showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        _setDataRange(value, endDate);
      }
    });
  }

  void _pickEndDate() {
    showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        _setDataRange(startDate, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GameReleaseList(
        platforms: platforms,
        startDate: startDate,
        endDate: endDate,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Filters'),
            ),
            PlatformSelection(
              platforms: platforms,
              myVoidCallback: _togglePlatform,
            ),
            ListTile(
              title: Text('Start Date: ${dateFormat.format(startDate)}'),
              onTap: _pickStartDate,
            ),
            ListTile(
              title: Text('End Date: ${dateFormat.format(endDate)}'),
              onTap: _pickEndDate,
            ),
          ],
        ),
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

class GameReleaseList extends StatefulWidget {
  GameReleaseList({
    super.key,
    required this.platforms,
    required this.startDate,
    required this.endDate,
  });

  final List<Platform> platforms;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<GameReleaseList> createState() => _GameReleaseListState();
}

class _GameReleaseListState extends State<GameReleaseList> {
  late Future<List<GameRelease>> futureGameReleases;

  @override
  void initState() {
    super.initState();
    futureGameReleases = fetchReleaseGames(
      widget.platforms,
      widget.startDate,
      widget.endDate,
    );
  }

  @override
  void didUpdateWidget(GameReleaseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.platforms != oldWidget.platforms ||
        widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      setState(() {
        futureGameReleases = fetchReleaseGames(
          widget.platforms,
          widget.startDate,
          widget.endDate,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameRelease>>(
      future: futureGameReleases,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No releases'));
          }

          return ListView(
            children: [
              for (var item in snapshot.data!) GameReleaseWidget(item: item),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
            '${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class GameReleaseWidget extends StatelessWidget {
  const GameReleaseWidget({super.key, required this.item});

  final GameRelease item;

  @override
  Widget build(BuildContext context) {
    var formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(item.date * 1000));

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
