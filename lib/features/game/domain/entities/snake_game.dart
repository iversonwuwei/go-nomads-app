/// 坐标位置领域实体
class Position {
  final int x;
  final int y;

  const Position({
    required this.x,
    required this.y,
  });

  /// 位置相等性比较
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  /// 位置加法运算
  Position operator +(Position other) {
    return Position(x: x + other.x, y: y + other.y);
  }

  /// 是否在边界内
  bool isWithinBounds(int maxX, int maxY) {
    return x >= 0 && x < maxX && y >= 0 && y < maxY;
  }

  /// 计算与另一个位置的曼哈顿距离
  int manhattanDistance(Position other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }
}

/// 移动方向枚举
enum Direction {
  up,
  down,
  left,
  right;

  /// 获取方向的反方向
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  /// 是否为水平方向
  bool get isHorizontal => this == Direction.left || this == Direction.right;

  /// 是否为垂直方向
  bool get isVertical => this == Direction.up || this == Direction.down;

  /// 获取方向向量
  Position get vector {
    switch (this) {
      case Direction.up:
        return const Position(x: 0, y: -1);
      case Direction.down:
        return const Position(x: 0, y: 1);
      case Direction.left:
        return const Position(x: -1, y: 0);
      case Direction.right:
        return const Position(x: 1, y: 0);
    }
  }
}

/// 游戏状态枚举
enum GameState {
  ready,
  playing,
  paused,
  gameOver;

  /// 是否可以继续游戏
  bool get canContinue => this == GameState.playing || this == GameState.paused;

  /// 是否游戏结束
  bool get isFinished => this == GameState.gameOver;

  /// 是否可以开始游戏
  bool get canStart => this == GameState.ready || this == GameState.gameOver;
}

/// 贪吃蛇领域实体
class Snake {
  final List<Position> body;
  final Direction direction;

  const Snake({
    required this.body,
    required this.direction,
  });

  /// 蛇头位置
  Position get head => body.first;

  /// 蛇尾位置
  Position get tail => body.last;

  /// 蛇的长度
  int get length => body.length;

  /// 移动蛇
  Snake move() {
    final newHead = head + direction.vector;
    final newBody = [newHead, ...body.sublist(0, body.length - 1)];
    return Snake(body: newBody, direction: direction);
  }

  /// 蛇成长(吃到食物)
  Snake grow() {
    final newHead = head + direction.vector;
    final newBody = [newHead, ...body];
    return Snake(body: newBody, direction: direction);
  }

  /// 改变方向
  Snake changeDirection(Direction newDirection) {
    // 防止反向移动
    if (newDirection == direction.opposite && body.length > 1) {
      return this;
    }
    return Snake(body: body, direction: newDirection);
  }

  /// 检查是否撞到自己
  bool checkSelfCollision() {
    return body.skip(1).contains(head);
  }

  /// 检查是否撞墙
  bool checkWallCollision(int maxX, int maxY) {
    return !head.isWithinBounds(maxX, maxY);
  }

  /// 检查是否吃到食物
  bool hasEatenFood(Position foodPosition) {
    return head == foodPosition;
  }
}

/// 食物领域实体
class Food {
  final Position position;

  const Food({
    required this.position,
  });

  /// 是否在指定位置
  bool isAt(Position pos) => position == pos;

  /// 是否被蛇占据
  bool isOccupiedBySnake(Snake snake) {
    return snake.body.contains(position);
  }
}

/// 贪吃蛇游戏数据领域实体
class SnakeGameData {
  final Snake snake;
  final Food food;
  final GameState state;
  final int score;
  final int highScore;
  final int gridWidth;
  final int gridHeight;

  const SnakeGameData({
    required this.snake,
    required this.food,
    required this.state,
    required this.score,
    required this.highScore,
    required this.gridWidth,
    required this.gridHeight,
  });

  /// 是否创建新的高分
  bool get isNewHighScore => score > highScore;

  /// 游戏难度(基于蛇的长度)
  String get difficulty {
    if (snake.length < 5) return 'easy';
    if (snake.length < 10) return 'medium';
    if (snake.length < 20) return 'hard';
    return 'expert';
  }

  /// 完成度(基于网格大小)
  double get completionPercentage {
    final totalCells = gridWidth * gridHeight;
    return (snake.length / totalCells) * 100;
  }

  /// 是否快要填满游戏区域
  bool get isNearlyFull => completionPercentage > 80;

  /// 游戏区域总格子数
  int get totalGridCells => gridWidth * gridHeight;

  /// 剩余可用空间
  int get remainingSpace => totalGridCells - snake.length;
}
