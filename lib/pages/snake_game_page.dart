import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/snake_game_controller.dart';
import '../models/snake_game_model.dart';

class SnakeGamePage extends StatelessWidget {
  const SnakeGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SnakeGameController controller = Get.put(SnakeGameController());

    return Scaffold(
      backgroundColor: const Color(0xFF1B2951),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2951),
        title: const Text(
          '贪吃蛇游戏',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonLight),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 分数显示
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        '分数: ${controller.gameData.value.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Obx(() => Text(
                        '长度: ${controller.gameData.value.snake.body.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      )),
                ],
              ),
            ),

            // 游戏区域
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3E5F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Obx(() => _buildGameGrid(controller)),
                ),
              ),
            ),

            // 游戏状态和控制按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Obx(() => _buildGameStateWidget(controller)),
                  const SizedBox(height: 20),
                  _buildControlButtons(controller),
                  const SizedBox(height: 20),
                  _buildDirectionPad(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGrid(SnakeGameController controller) {
    return AspectRatio(
      aspectRatio: SnakeGameController.defaultGridWidth /
          SnakeGameController.defaultGridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.gameData.value.gridWidth,
        ),
        itemCount: controller.gameData.value.gridWidth *
            controller.gameData.value.gridHeight,
        itemBuilder: (context, index) {
          int x = index % controller.gameData.value.gridWidth;
          int y = index ~/ controller.gameData.value.gridWidth;
          Position currentPos = Position(x, y);

          return Container(
            decoration: BoxDecoration(
              color: _getCellColor(currentPos, controller),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: _getCellContent(currentPos, controller),
          );
        },
      ),
    );
  }

  Color _getCellColor(Position pos, SnakeGameController controller) {
    // 蛇头
    if (pos == controller.gameData.value.snake.head) {
      return const Color(0xFF4CAF50);
    }
    // 蛇身
    if (controller.gameData.value.snake.body.contains(pos)) {
      return const Color(0xFF66BB6A);
    }
    // 食物
    if (pos == controller.gameData.value.food.position) {
      return const Color(0xFFFF5722);
    }
    // 空格
    return Colors.transparent;
  }

  Widget? _getCellContent(Position pos, SnakeGameController controller) {
    if (pos == controller.gameData.value.snake.head) {
      return const Icon(
        Icons.circle,
        color: Colors.white,
        size: 8,
      );
    }
    if (pos == controller.gameData.value.food.position) {
      return const Icon(
        Icons.circle,
        color: Colors.white,
        size: 6,
      );
    }
    return null;
  }

  Widget _buildGameStateWidget(SnakeGameController controller) {
    switch (controller.gameData.value.gameState) {
      case GameState.ready:
        return const Text(
          '准备开始游戏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      case GameState.playing:
        return const Text(
          '游戏进行�?..',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      case GameState.paused:
        return const Text(
          '游戏已暂停',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      case GameState.gameOver:
        return Column(
          children: [
            const Text(
              '游戏结束!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '最终分�? ${controller.gameData.value.score}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildControlButtons(SnakeGameController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => ElevatedButton(
              onPressed: controller.gameData.value.gameState ==
                          GameState.ready ||
                      controller.gameData.value.gameState == GameState.paused
                  ? controller.startGame
                  : controller.gameData.value.gameState == GameState.playing
                      ? controller.pauseGame
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                controller.gameData.value.gameState == GameState.playing
                    ? '暂停'
                    : '开始',
              ),
            )),
        ElevatedButton(
          onPressed: controller.resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5722),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('重置'),
        ),
      ],
    );
  }

  Widget _buildDirectionPad(SnakeGameController controller) {
    return Column(
      children: [
        const Text(
          '方向控制',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            // �?
            _buildDirectionButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: () => controller.changeDirection(Direction.up),
            ),
            const SizedBox(height: 8),
            // 左右
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDirectionButton(
                  icon: Icons.keyboard_arrow_left,
                  onPressed: () => controller.changeDirection(Direction.left),
                ),
                const SizedBox(width: 60),
                _buildDirectionButton(
                  icon: Icons.keyboard_arrow_right,
                  onPressed: () => controller.changeDirection(Direction.right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // �?
            _buildDirectionButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: () => controller.changeDirection(Direction.down),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
