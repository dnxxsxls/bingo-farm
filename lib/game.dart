import 'package:flame/game.dart';
import 'game_state.dart';
import 'tile_component.dart';

class TileFarmGame extends FlameGame {
  final GameState gameState;
  final int boardSize = 3;
  double tileSize = 0;
  double boardPadding = 20;

  TileFarmGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 화면 크기가 설정된 후 타일 업데이트
    Future.microtask(() {
      if (size.x > 0 && size.y > 0) {
        _updateTiles();
      }
    });
  }

  void _updateTiles() {
    // 화면 크기가 유효하지 않으면 스킵
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    // 기존 타일 제거
    final tilesToRemove = children.whereType<TileComponent>().toList();
    for (final tile in tilesToRemove) {
      remove(tile);
    }

    // 화면 크기 계산
    final screenWidth = size.x;
    final screenHeight = size.y;
    final availableWidth = screenWidth - (boardPadding * 2);
    final availableHeight = screenHeight - (boardPadding * 2);
    tileSize = (availableWidth / boardSize).clamp(0.0, availableHeight / boardSize);

    final boardWidth = tileSize * boardSize;
    final boardHeight = tileSize * boardSize;
    final startX = (screenWidth - boardWidth) / 2;
    final startY = (screenHeight - boardHeight) / 2;

    // 타일 생성
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final tile = gameState.tiles[row][col];
        final tileComponent = TileComponent(
          tile: tile,
          row: row,
          col: col,
          onTap: () => _handleTileTap(row, col),
          position: Vector2(
            startX + col * tileSize,
            startY + row * tileSize,
          ),
          size: Vector2(tileSize, tileSize),
        );
        add(tileComponent);
      }
    }
  }

  void _handleTileTap(int row, int col) {
    if (gameState.canPlant(row, col)) {
      gameState.plantCrop(row, col);
    } else if (gameState.canHarvest(row, col)) {
      gameState.harvestCrop(row, col);
    }
    _updateTiles();
  }

  void refreshTiles() {
    gameState.updateTiles();
    _updateTiles();
  }
}
