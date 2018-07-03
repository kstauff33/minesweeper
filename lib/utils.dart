bool isInSetMap(int x, int y, Map<int, Set<int>> map) {
  return map.containsKey(x) && map[x].contains(y);
}

List<List<int>> permute(List<int> x, List<int> y) {
  var pairs = <List<int>>[];

  for (int a in x) {
    for (int b in y) {
      pairs.add([a, b]);
    }
  }
  return pairs;
}
