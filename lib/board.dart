import 'dart:math';

import 'package:minesweeper/cell_data.dart';
import 'package:minesweeper/utils.dart';

class Board {
  List<List<CellData>> board;
  final int bombs;

  Board(int width, int height, this.bombs) {
    final bombMap = _chooseBombs(height, width);
    board = List.generate(width, (x) {
      return List.generate(height, (y) {
        var neighbors = permute([x - 1, x, x + 1], [y - 1, y, y + 1]);
        var adjacentBombs = neighbors
            .where((pair) => pair[0] != x || pair[1] != y)
            .where((pair) => isInSetMap(pair[0], pair[1], bombMap))
            .toList()
            .length;
        return CellData(x, y, isInSetMap(x, y, bombMap), adjacentBombs);
      });
    });
  }

  _chooseBombs(int height, int width) {
    var x = List.generate(width, (n) => n);
    var y = List.generate(height, (n) => n);

    List<List<int>> pairs = permute(x, y)
      ..shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    Map<int, Set<int>> bombMap = {};
    pairs.take(bombs).forEach((List<int> point) {
      bombMap.putIfAbsent(point[0], () => Set<int>());
      bombMap[point[0]].add(point[1]);
    });
    return bombMap;
  }

  CellData getForPosition(int x, int y) {
    return board[x][y];
  }

  void floodFill(int x, int y) {
    if (x >= board.length ||
        x < 0 ||
        y >= board[x].length ||
        y < 0 ||
        board[x][y].state != CellState.blank) {
      return;
    }
    board[x][y].open();
    if (board[x][y].adjacentBombs == 0) {
      floodFill(x + 1, y);
      floodFill(x - 1, y);
      floodFill(x, y - 1);
      floodFill(x, y + 1);
    }
  }

  bool shouldEndGame() {
    int freeCells = board.fold(0, (num count, List<CellData> row) {
      int sub = row.fold(0, (num prev, CellData cell) {
        return (cell.state == CellState.blank ||
                cell.state == CellState.flagged)
            ? prev + 1
            : prev;
      });
      return sub + count;
    });

    return freeCells == bombs;
  }
}
