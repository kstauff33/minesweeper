enum CellState { blank, flagged, opened }

class CellData {
  final bool hasBomb;
  final int surrounding;
  final int x;
  final int y;
  CellState state = CellState.blank;
  Function onFloodFilled = () {};

  CellData(this.x, this.y, this.hasBomb, this.surrounding);

  void floodFilled() {
    state = CellState.opened;
    onFloodFilled();
  }
}
