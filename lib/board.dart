import 'dart:math';

import 'package:minesweeper/cell_data.dart';
import 'package:minesweeper/utils.dart';

class Board {
  List<List<CellData>> board;
  final int bombs;

  Board(int width, int height, this.bombs) {
    List<int> x = List.generate(width, (n) => n);
    List<int> y = List.generate(height, (n) => n);

    List<List<int>> pairs = permute(x, y)
      ..shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    Map<int, Set<int>> bombMap = {};
    pairs.take(bombs).forEach((List<int> point) {
      bombMap.putIfAbsent(point[0], () => Set<int>());
      bombMap[point[0]].add(point[1]);
    });

    board = List.generate(width, (x) {
      return List.generate(height, (y) {
        var pairs = permute([x - 1, x, x + 1], [y - 1, y, y + 1]);
        var count = 0;
        for (var pair in pairs) {
          var x0 = pair[0];
          var y0 = pair[1];
          if (!(x == x0 && y == y0) && isInSetMap(x0, y0, bombMap)) {
            count++;
          }
        }
        return CellData(x, y, isInSetMap(x, y, bombMap), count);
      });
    });
  }

  void floodFill(int x, int y) {
    if (x >= board.length ||
        x < 0 ||
        y >= board[x].length ||
        y < 0 ||
        board[x][y].state != CellState.blank) {
      return;
    }
    board[x][y].floodFilled();
    if (board[x][y].surrounding == 0) {
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
