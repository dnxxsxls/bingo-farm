import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'models/crop_type.dart';
import 'models/tile_state.dart';
import 'game_state.dart';
import 'tile_component.dart';

class TileFarmGame extends FlameGame {
  final GameState gameState;
  final int boardSize = 3;
  double tileSize = 0;
  double boardPadding = 0; // 타일을 다닥다닥 붙이기 위해 패딩 제거
  late ui.Image emptyTileImage;
  late ui.Image backgroundImage;
  
  // 작물별 성장 단계별 이미지 맵
  final Map<String, ui.Image> cropImages = {};
  
  @override
  Color backgroundColor() => Colors.transparent; // 게임 배경 투명하게

  TileFarmGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 배경 이미지와 빈 타일 이미지 로드
    backgroundImage = await images.load('bg.png');
    emptyTileImage = await images.load('farm_empty.png');
    
    // 작물별 성장 단계별 이미지 로드
    await _loadCropImages();
    
    // 화면 크기가 설정된 후 배경과 타일 업데이트
    Future.microtask(() {
      if (size.x > 0 && size.y > 0) {
        _addBackground();
        _updateTiles();
      }
    });
  }
  
  Future<void> _loadCropImages() async {
    // 작물 목록과 단계 목록
    final crops = ['carrot', 'potato', 'corn', 'tomato', 'taro', 'eggplant', 'bean', 'watermelon', 'pumpkin'];
    final stages = ['seed', 'sprout', 'seedling', 'youngplant', 'harvest'];
    
    for (final crop in crops) {
      for (final stage in stages) {
        try {
          final image = await images.load('farm_${stage}_$crop.png');
          cropImages['${crop}_${stage}'] = image;
        } catch (e) {
          // 이미지가 없으면 무시 (일부 작물은 아직 이미지가 없을 수 있음)
        }
      }
    }
  }
  
  ui.Image? getCropImage(CropType cropType, TileState state) {
    if (state == TileState.empty) return null;
    
    final cropName = _getCropName(cropType);
    final stageName = _getStageName(state);
    final key = '${cropName}_$stageName';
    return cropImages[key];
  }
  
  String _getCropName(CropType cropType) {
    switch (cropType) {
      case CropType.carrot: return 'carrot';
      case CropType.potato: return 'potato';
      case CropType.corn: return 'corn';
      case CropType.tomato: return 'tomato';
      case CropType.taro: return 'taro';
      case CropType.eggplant: return 'eggplant';
      case CropType.bean: return 'bean';
      case CropType.watermelon: return 'watermelon';
      case CropType.pumpkin: return 'pumpkin';
    }
  }
  
  String _getStageName(TileState state) {
    switch (state) {
      case TileState.seed: return 'seed';
      case TileState.sprout: return 'sprout';
      case TileState.seedling: return 'seedling';
      case TileState.youngplant: return 'youngplant';
      case TileState.harvest: return 'harvest';
      case TileState.empty: return '';
    }
  }

  void _addBackground() {
    // 기존 배경 제거
    final existingBackground = children.whereType<SpriteComponent>().where((c) => c.priority == -1).toList();
    for (final bg in existingBackground) {
      remove(bg);
    }
    
    // 배경 컴포넌트 생성 - priority를 낮게 설정하여 가장 아래에 그려지도록
    final background = SpriteComponent(
      sprite: Sprite(backgroundImage),
      size: size,
      position: Vector2.zero(),
      priority: -1, // 가장 아래 레이어
    );
    add(background);
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

    // 타일 생성 - 간격 없이 다닥다닥 붙이기 위해 위치 정밀 조정
    // 재배기 이미지가 붙어보이도록 오버랩 증가
    final overlap = 10.0; // 10픽셀 오버랩으로 재배기 간격 최소화
    final adjustedTileSize = tileSize + overlap;
    
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final tile = gameState.tiles[row][col];
        final tileComponent = TileComponent(
          tile: tile,
          row: row,
          col: col,
          onTap: () => _handleTileTap(row, col),
          position: Vector2(
            startX + col * (tileSize - overlap),
            startY + row * (tileSize - overlap),
          ),
          size: Vector2(adjustedTileSize, adjustedTileSize),
          emptyTileImage: emptyTileImage,
          game: this,
        );
        add(tileComponent);
      }
    }
  }

  void _handleTileTap(int row, int col) {
    bool changed = false;
    if (gameState.canPlant(row, col)) {
      gameState.plantCrop(row, col);
      changed = true;
    } else if (gameState.canHarvest(row, col)) {
      gameState.harvestCrop(row, col);
      changed = true;
    }
    
    // 상태가 변경되면 즉시 타일 업데이트
    if (changed) {
      gameState.updateTiles(); // 상태 먼저 업데이트
      _updateTiles(); // 타일 컴포넌트 다시 생성
    }
  }

  void refreshTiles() {
    // 상태 업데이트 후 타일 컴포넌트를 항상 다시 생성하여 이미지가 업데이트되도록 함
    gameState.updateTiles();
    _updateTiles();
  }
}
