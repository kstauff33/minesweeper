import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/board.dart';
import 'package:minesweeper/cell.dart';
import 'package:minesweeper/cell_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Minesweeper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _gameActive = true;
  int height = 18, width = 10, bombs = 15;

  bool gameActive() => _gameActive;

  @override
  Widget build(BuildContext context) {
    var board = Board(height, width, bombs);
    Size deviceSize = MediaQuery.of(context).size;
    var cellWidth = deviceSize.width / width;
    var cellHeight = deviceSize.height / height - 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reset,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: board.board.map((List<CellData> row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((CellData data) => Cell(
                      data: data,
                      cellWidth: cellWidth,
                      cellHeight: cellHeight,
                      onGameEnded: _onGameEnded,
                      isGameActive: gameActive,
                      board: board))
                  .toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  _onGameEnded(bool won) {
    _gameActive = false;
    if (won) {
      _showAlertDialog('You won!');
    } else {
      _showAlertDialog('You lost..');
    }
  }

  _showAlertDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              onPressed: () => setState(() {
                    Navigator.of(context).pop();
                    _openSettings();
                  }),
              child: Text('Settings'),
            ),
            FlatButton(
              onPressed: () {
                _reset();
                Navigator.of(context).pop();
              },
              child: Text('Play again'),
            ),
          ],
        );
      },
    );
  }

  _reset() {
    setState(() {
      _gameActive = true;
    });
  }

  void _openSettings() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController heightControl =
              TextEditingController(text: '$height');
          TextEditingController widthControl =
              TextEditingController(text: '$width');
          TextEditingController bombsControl =
              TextEditingController(text: '$bombs');
          return AlertDialog(
            title: Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _getSettingsTextRow('Height', heightControl),
                _getSettingsTextRow('Width', widthControl),
                _getSettingsTextRow('Bombs', bombsControl),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Save'),
                onPressed: () =>
                    _saveSettings(heightControl, widthControl, bombsControl),
              )
            ],
          );
        });
  }

  Widget _getSettingsTextRow(String text, TextEditingController controller) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.end,
      maxLength: 2,
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter(new RegExp('[0-9]+'))],
      decoration: InputDecoration(
        hintText: text,
        counterText: '',
        fillColor: Theme.of(context).primaryColorLight,
      ),
    );
  }

  _saveSettings(TextEditingController heightControl,
      TextEditingController widthControl, TextEditingController bombsControl) {
    var height = heightControl.value.text;
    var width = widthControl.value.text;
    var bombs = bombsControl.value.text;
    try {
      this.height = int.parse(height);
    } catch (e) {}
    try {
      this.width = int.parse(width);
    } catch (e) {}
    try {
      this.bombs = int.parse(bombs);
    } catch (e) {}
    _reset();
    Navigator.of(context).pop();
  }
}
