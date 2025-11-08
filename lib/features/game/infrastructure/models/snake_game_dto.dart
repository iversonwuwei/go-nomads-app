import '../../../../models/snake_game_model.dart' as legacy;
import '../../domain/entities/snake_game.dart';

/// 坐标位置数据传输对象
class PositionDto {
  final int x;
  final int y;

  PositionDto({
    required this.x,
    required this.y,
  });

  factory PositionDto.fromJson(Map<String, dynamic> json) {
    return PositionDto(
      x: json['x'] as int,
      y: json['y'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  Position toDomain() {
    return Position(
      x: x,
      y: y,
    );
  }

  static PositionDto fromLegacyModel(legacy.Position model) {
    return PositionDto(
      x: model.x,
      y: model.y,
    );
  }
}

/// 贪吃蛇数据传输对象
class SnakeDto {
  final List<PositionDto> body;
  final String direction; // 'up', 'down', 'left', 'right'

  SnakeDto({
    required this.body,
    required this.direction,
  });

  factory SnakeDto.fromJson(Map<String, dynamic> json) {
    return SnakeDto(
      body: (json['body'] as List<dynamic>)
          .map((e) => PositionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      direction: json['direction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body.map((e) => e.toJson()).toList(),
      'direction': direction,
    };
  }

  Snake toDomain() {
    return Snake(
      body: body.map((e) => e.toDomain()).toList(),
      direction: _directionFromString(direction),
    );
  }

  static SnakeDto fromLegacyModel(legacy.Snake model) {
    return SnakeDto(
      body: model.body.map((e) => PositionDto.fromLegacyModel(e)).toList(),
      direction: _directionToString(model.direction),
    );
  }

  static Direction _directionFromString(String dir) {
    switch (dir) {
      case 'up':
        return Direction.up;
      case 'down':
        return Direction.down;
      case 'left':
        return Direction.left;
      case 'right':
        return Direction.right;
      default:
        return Direction.right;
    }
  }

  static String _directionToString(legacy.Direction dir) {
    switch (dir) {
      case legacy.Direction.up:
        return 'up';
      case legacy.Direction.down:
        return 'down';
      case legacy.Direction.left:
        return 'left';
      case legacy.Direction.right:
        return 'right';
    }
  }
}

/// 食物数据传输对象
class FoodDto {
  final PositionDto position;

  FoodDto({
    required this.position,
  });

  factory FoodDto.fromJson(Map<String, dynamic> json) {
    return FoodDto(
      position: PositionDto.fromJson(json['position'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
    };
  }

  Food toDomain() {
    return Food(
      position: position.toDomain(),
    );
  }

  static FoodDto fromLegacyModel(legacy.Food model) {
    return FoodDto(
      position: PositionDto.fromLegacyModel(model.position),
    );
  }
}

/// 贪吃蛇游戏数据传输对象
class SnakeGameDataDto {
  final SnakeDto snake;
  final FoodDto food;
  final String state; // 'ready', 'playing', 'paused', 'gameOver'
  final int score;
  final int highScore;
  final int gridWidth;
  final int gridHeight;

  SnakeGameDataDto({
    required this.snake,
    required this.food,
    required this.state,
    required this.score,
    required this.highScore,
    required this.gridWidth,
    required this.gridHeight,
  });

  factory SnakeGameDataDto.fromJson(Map<String, dynamic> json) {
    return SnakeGameDataDto(
      snake: SnakeDto.fromJson(json['snake'] as Map<String, dynamic>),
      food: FoodDto.fromJson(json['food'] as Map<String, dynamic>),
      state: json['state'] as String,
      score: json['score'] as int,
      highScore: json['highScore'] as int,
      gridWidth: json['gridWidth'] as int,
      gridHeight: json['gridHeight'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snake': snake.toJson(),
      'food': food.toJson(),
      'state': state,
      'score': score,
      'highScore': highScore,
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
    };
  }

  SnakeGameData toDomain() {
    return SnakeGameData(
      snake: snake.toDomain(),
      food: food.toDomain(),
      state: _stateFromString(state),
      score: score,
      highScore: highScore,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );
  }

  static SnakeGameDataDto fromLegacyModel(legacy.SnakeGameData model) {
    return SnakeGameDataDto(
      snake: SnakeDto.fromLegacyModel(model.snake),
      food: FoodDto.fromLegacyModel(model.food),
      state: _stateToString(model.state),
      score: model.score,
      highScore: model.highScore,
      gridWidth: model.gridWidth,
      gridHeight: model.gridHeight,
    );
  }

  static GameState _stateFromString(String state) {
    switch (state) {
      case 'ready':
        return GameState.ready;
      case 'playing':
        return GameState.playing;
      case 'paused':
        return GameState.paused;
      case 'gameOver':
        return GameState.gameOver;
      default:
        return GameState.ready;
    }
  }

  static String _stateToString(legacy.GameState state) {
    switch (state) {
      case legacy.GameState.ready:
        return 'ready';
      case legacy.GameState.playing:
        return 'playing';
      case legacy.GameState.paused:
        return 'paused';
      case legacy.GameState.gameOver:
        return 'gameOver';
    }
  }
}
