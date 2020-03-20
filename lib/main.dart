import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/cell.dart';
import 'package:minesweeper/cell_data.dart';
import 'package:minesweeper/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((preferences) {
    runApp(Minesweeper(preferences));
  });
}

class Minesweeper extends StatelessWidget {
  final SharedPreferences preferences;

  Minesweeper(this.preferences);

  @override
  Widget build(BuildContext context) {
    return Preferences(
      bloc: PreferencesBloc(preferences: preferences),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
//        WillPopScope(
//          onWillPop: () async => false,
//          child:
//        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final game = Game();

  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferences = Preferences.of(context);
    preferences.state.where((event) => event is OpenSettings).listen((event) {
      showDialog(context: context, builder: (context) => SettingsPanel())
          .then((value) => _newGame(context));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _newGame(context),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => preferences.state.add(OpenSettings()),
          )
        ],
      ),
      body: GameProvider(
        game: game
          ..newGame(
            columns: preferences.columns,
            rows: preferences.rows,
            bombs: preferences.bombs,
          ),
        child: GameWidget(),
      ),
    );
  }

  void _newGame(BuildContext context) {
    game.newGameFromPreferences(Preferences.of(context));
  }
}

class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final preferences = Preferences.of(context);
    final deviceSize = MediaQuery.of(context).size;
    var cellWidth = deviceSize.width / preferences.columns;
    var cellHeight = (deviceSize.height - 125) / preferences.rows;
    final cellSize = min(cellHeight, cellWidth);

    final game = GameProvider.of(context);

    game.state.where((event) => event is GameOver).listen((event) {
      showModalBottomSheet(
        context: context,
        builder: (context) => GameProvider(
          game: game,
          child: GameOverWidget(won: (event as GameOver).won),
        ),
      );
    });

    return StreamBuilder<GameState>(
      stream: game.state,
      builder: (context, snapshot) {
        return SafeArea(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: game.board.board.map((List<CellData> row) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map((CellData data) => Cell(
                            data: data,
                            cellSize: cellSize,
                            key: Key('${data.x} | ${data.y}'),
                          ))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class GameOverWidget extends StatelessWidget {
  final bool won;

  const GameOverWidget({Key key, this.won}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = GameProvider.of(context);
    final preferences = Preferences.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You ${won ? "Won" : "Lost"}!',
            style: TextStyle(fontSize: 32),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                onPressed: () => preferences.state.add(OpenSettings()),
                color: Theme.of(context).primaryColor,
                child: Text('Settings', style: TextStyle(color: Colors.white)),
              ),
              Padding(padding: EdgeInsets.all(8)),
              MaterialButton(
                onPressed: () {
                  game.newGameFromPreferences(preferences);
                  Navigator.of(context).pop();
                },
                color: Theme.of(context).primaryColor,
                child: Text('New game', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
