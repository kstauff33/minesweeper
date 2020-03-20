enum CellState { blank, flagged, opened }

class CellData {
  final bool hasBomb;
  final int adjacentBombs;
  final int x;
  final int y;
  CellState state = CellState.blank;

  CellData(this.x, this.y, this.hasBomb, this.adjacentBombs);

  void open() {
    state = CellState.opened;
  }

  void flag() {
    state = CellState.flagged;
  }

  void clear() {
    state = CellState.blank;
  }
}
