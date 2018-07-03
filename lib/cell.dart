import 'package:flutter/material.dart';
import 'package:minesweeper/board.dart';
import 'package:minesweeper/cell_data.dart';

class Cell extends StatefulWidget {
  final CellData data;
  final double cellWidth, cellHeight;
  final Board board;
  final Function onGameEnded;
  final Function isGameActive;

  const Cell(
      {Key key,
      this.data,
      this.cellWidth,
      this.cellHeight,
      this.board,
      this.onGameEnded,
      this.isGameActive})
      : super(key: key);

  @override
  _CellState createState() => new _CellState();
}

class _CellState extends State<Cell> {
  set state(CellState newState) {
    widget.data.state = newState;
  }

  @override
  Widget build(BuildContext context) {
    widget.data.onFloodFilled = _onFloodFilled;
    return GestureDetector(
      onTap: _tapped,
      onLongPress: _longPressed,
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          height: widget.cellWidth - 6.0,
          width: widget.cellWidth - 6.0,
          color: _backgroundColor(),
          child: Center(child: _getInternal()),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (widget.data.hasBomb) {
      return Colors.grey.shade300;
    }
    if (widget.data.surrounding == 0 && widget.data.state == CellState.opened) {
      return Colors.grey.shade600;
    }
    return Colors.grey.shade300;
  }

  _getInternal() {
    switch (widget.data.state) {
      case CellState.flagged:
        return Icon(Icons.flag, color: Colors.red);
      case CellState.opened:
        if (widget.data.hasBomb) {
          return Icon(Icons.cancel);
        }
        if (widget.data.surrounding == 0) {
          return Padding(padding: EdgeInsets.all(0.0));
        }
        return Text(
          '${widget.data.surrounding}',
          style: TextStyle(
            color: _textColor(widget.data.surrounding),
            fontWeight: FontWeight.bold,
          ),
        );
      case CellState.blank:
        return Padding(padding: EdgeInsets.all(0.0));
    }
  }

  void _tapped() {
    if (widget.isGameActive()) {
      switch (widget.data.state) {
        case CellState.opened:
          break;
        case CellState.flagged:
          break;
        case CellState.blank:
          if (widget.data.hasBomb) {
            widget.onGameEnded(false);
          } else {
            widget.board.floodFill(widget.data.x, widget.data.y);
          }
          if (widget.board.shouldEndGame()) {
            widget.onGameEnded(true);
          }
          setState(() {
            state = CellState.opened;
          });
          break;
      }
    }
  }

  void _longPressed() {
    if (widget.isGameActive()) {
      switch (widget.data.state) {
        case CellState.opened:
          break;
        case CellState.flagged:
          setState(() {
            state = CellState.blank;
          });
          break;
        case CellState.blank:
          setState(() {
            state = CellState.flagged;
          });
      }
    }
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

  _onFloodFilled() {
    setState(() {});
  }
}
