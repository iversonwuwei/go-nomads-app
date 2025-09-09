import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../models/snake_game_model.dart';

class SnakeGameController extends GetxController {
  static const int defaultGridWidth = 20;
  static const int defaultGridHeight = 30;
  static const int gameDuration = 300; // 毫秒

  // 游戏状态
  var gameData = SnakeGameData(
    snake: Snake(body: [Position(10, 15)], direction: Direction.right),
    food: Food(Position(5, 5)),
    gameState: GameState.ready,
    score: 0,
    gridWidth: defaultGridWidth,
    gridHeight: defaultGridHeight,
  ).obs;

  Timer? _gameTimer;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }

  void _initializeGame() {
    gameData.value = SnakeGameData(
      snake: Snake(
        body: [Position(defaultGridWidth ~/ 2, defaultGridHeight ~/ 2)],
        direction: Direction.right,
      ),
      food: _generateFood(),
      gameState: GameState.ready,
      score: 0,
      gridWidth: defaultGridWidth,
      gridHeight: defaultGridHeight,
    );
  }

  void startGame() {
    if (gameData.value.gameState == GameState.ready ||
        gameData.value.gameState == GameState.paused) {
      gameData.update((data) {
        data!.gameState = GameState.playing;
      });
      _startGameLoop();
    }
  }

  void pauseGame() {
    if (gameData.value.gameState == GameState.playing) {
      gameData.update((data) {
        data!.gameState = GameState.paused;
      });
      _gameTimer?.cancel();
    }
  }

  void resetGame() {
    _gameTimer?.cancel();
    _initializeGame();
  }

  void changeDirection(Direction newDirection) {
    if (gameData.value.gameState != GameState.playing) return;

    // 防止反向移动
    Direction currentDirection = gameData.value.snake.direction;
    if (_isOppositeDirection(currentDirection, newDirection)) return;

    gameData.update((data) {
      data!.snake.direction = newDirection;
    });
  }

  void _startGameLoop() {
    _gameTimer =
        Timer.periodic(const Duration(milliseconds: gameDuration), (timer) {
      if (gameData.value.gameState == GameState.playing) {
        _updateGame();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateGame() {
    // 移动蛇
    gameData.value.snake.move();

    // 检查墙壁碰撞
    if (_checkWallCollision()) {
      _gameOver();
      return;
    }

    // 检查自身碰撞
    if (gameData.value.snake.checkSelfCollision()) {
      _gameOver();
      return;
    }

    // 检查食物碰撞
    if (gameData.value.snake.head == gameData.value.food.position) {
      _eatFood();
    } else {
      gameData.value.snake.removeTail();
    }

    gameData.refresh();
  }

  bool _checkWallCollision() {
    Position head = gameData.value.snake.head;
    return head.x < 0 ||
        head.x >= gameData.value.gridWidth ||
        head.y < 0 ||
        head.y >= gameData.value.gridHeight;
  }

  void _eatFood() {
    // 蛇增长（不移除尾部）
    gameData.update((data) {
      data!.score += 10;
      data.food = _generateFood();
    });
  }

  Food _generateFood() {
    Position newPosition;
    do {
      newPosition = Position(
        _random.nextInt(gameData.value.gridWidth),
        _random.nextInt(gameData.value.gridHeight),
      );
    } while (gameData.value.snake.body.contains(newPosition));

    return Food(newPosition);
  }

  void _gameOver() {
    _gameTimer?.cancel();
    gameData.update((data) {
      data!.gameState = GameState.gameOver;
    });
  }

  bool _isOppositeDirection(Direction current, Direction newDirection) {
    switch (current) {
      case Direction.up:
        return newDirection == Direction.down;
      case Direction.down:
        return newDirection == Direction.up;
      case Direction.left:
        return newDirection == Direction.right;
      case Direction.right:
        return newDirection == Direction.left;
    }
  }

  // 自动启动游戏（用于超时触发）
  void autoStartGame() {
    if (gameData.value.gameState == GameState.ready) {
      startGame();
    }
  }
}
