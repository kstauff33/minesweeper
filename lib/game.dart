import 'package:flutter/material.dart';
import 'package:minesweeper/settings.dart';
import 'package:rxdart/rxdart.dart';

import 'board.dart';
import 'cell_data.dart';

class GameProvider extends InheritedWidget {
  final Game game;

  GameProvider({this.game, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static Game of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<GameProvider>().game;
}

class Game {
  Board board;
  int rows;
  int columns;
  int bombs;

  bool isActive = true;

  BehaviorSubject<GameState> state = BehaviorSubject<GameState>();

  Game() {
    state.where((event) => event is GameOver).listen((event) {
      isActive = false;
    });
    state.where((event) => event is NewGame).listen((event) {
      isActive = true;
    });
  }

  newGame({int rows, int columns, int bombs}) {
    this.rows = rows;
    this.columns = columns;
    this.bombs = bombs;
    this.board = Board(columns, rows, bombs);
    state.add(NewGame());
  }

  newGameFromPreferences(PreferencesBloc preferences) {
    newGame(
      rows: preferences.rows,
      columns: preferences.columns,
      bombs: preferences.bombs,
    );
  }

  selectCell(int x, int y) {
    if (isActive) {
      var cell = board.getForPosition(x, y);
      if (cell.state == CellState.blank) {
        if (cell.hasBomb) {
          cell.open();
          state.add(GameOver(false));
          return;
        }
        board.floodFill(x, y);
        state.add(CellUpdated(x, y));
        if (board.shouldEndGame()) {
          state.add(GameOver(true));
        }
      }
    }
  }

  flagCell(int x, int y) {
    if (isActive) {
      var cell = board.getForPosition(x, y);
      if (cell.state == CellState.flagged) {
        cell.state = CellState.blank;
        state.add(CellUpdated(x, y));
      } else if (cell.state == CellState.blank) {
        cell.state = CellState.flagged;
        state.add(CellUpdated(x, y));
      }

      if (board.shouldEndGame()) {
        state.add(GameOver(true));
      }
    }
  }

  dispose() {
    state.close();
  }
}

class GameState {}

class NewGame extends GameState {}

class CellUpdated extends GameState {
  final int x;
  final int y;

  CellUpdated(this.x, this.y);
}

class GameOver extends GameState {
  final bool won;

  GameOver(this.won);
}
