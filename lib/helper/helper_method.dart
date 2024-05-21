bool isWhite (int index) {
  int x = index ~/ 8; // integer division row
  int y = index % 8; // remainder column

  // altanate colors for each sqare
  bool isWhite = (x + y) % 2 ==0;

  return isWhite;
}