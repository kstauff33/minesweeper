import 'package:flutter/material.dart';
import 'package:minesweeper/cell_data.dart';

import 'game.dart';

class Cell extends StatelessWidget {
  final CellData data;
  final double cellSize;

  const Cell({
    Key key,
    @required this.data,
    @required this.cellSize,
  }) : super(key: key);

  set state(CellState newState) {
    data.state = newState;
  }

  @override
  Widget build(BuildContext context) {
    final game = GameProvider.of(context);

//    return StreamBuilder<GameState>(
//      stream: game.state.where(),
//      builder: (context, snapshot) {},
//    );

    return GestureDetector(
      onTap: () => game.selectCell(data.x, data.y),
      onLongPress: () => game.flagCell(data.x, data.y),
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          height: cellSize - 6.0,
          width: cellSize - 6.0,
          color: _backgroundColor(),
          child: Center(child: _getInternal(context)),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (data.hasBomb) {
      return Colors.grey.shade300;
    }
    if (data.adjacentBombs == 0 && data.state == CellState.opened) {
      return Colors.grey.shade600;
    }
    return Colors.grey.shade300;
  }

  Widget _flagIcon() => Icon(Icons.flag, color: Colors.red);

  Widget _bombIcon() => Icon(Icons.cancel);

  _getInternal(BuildContext context) {
    var lastEvent = GameProvider.of(context).state.value;
    if (lastEvent is GameOver && data.hasBomb) {
      if (data.state == CellState.flagged) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _flagIcon(),
            _bombIcon(),
          ],
        );
      }
      return _bombIcon();
    }

    if (data.state == CellState.flagged) {
      return _flagIcon();
    }

    if (data.state == CellState.opened) {
      if (data.hasBomb) {
        return _bombIcon();
      }

      if (data.adjacentBombs == 0) {
        return Padding(padding: EdgeInsets.all(0.0));
      }

      return Text(
        '${data.adjacentBombs}',
        style: TextStyle(
          color: _textColor(data.adjacentBombs),
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Padding(padding: EdgeInsets.all(0.0));
  }

  Color _textColor(int val) {
    switch (val) {
      case 1:
        return Colors.deepOrange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.pink;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.green;
      case 7:
        return Colors.teal;
      case 8:
        return Colors.yellow;
    }
    return Colors.black;
  }
}
