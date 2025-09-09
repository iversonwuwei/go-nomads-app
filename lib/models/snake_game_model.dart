class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Position operator +(Position other) {
    return Position(x + other.x, y + other.y);
  }
}

enum Direction { up, down, left, right }

enum GameState { ready, playing, paused, gameOver }

class Snake {
  List<Position> body;
  Direction direction;

  Snake({required this.body, required this.direction});

  Position get head => body.first;

  void move() {
    Position newHead = head + _getDirectionOffset(direction);
    body.insert(0, newHead);
  }

  void grow() {
    // Don't remove tail when growing
  }

  void removeTail() {
    if (body.isNotEmpty) {
      body.removeLast();
    }
  }

  bool checkSelfCollision() {
    return body.skip(1).contains(head);
  }

  Position _getDirectionOffset(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(0, -1);
      case Direction.down:
        return Position(0, 1);
      case Direction.left:
        return Position(-1, 0);
      case Direction.right:
        return Position(1, 0);
    }
  }
}

class Food {
  Position position;

  Food(this.position);
}

class SnakeGameData {
  Snake snake;
  Food food;
  GameState gameState;
  int score;
  int gridWidth;
  int gridHeight;

  SnakeGameData({
    required this.snake,
    required this.food,
    required this.gameState,
    required this.score,
    required this.gridWidth,
    required this.gridHeight,
  });
}
