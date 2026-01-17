import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'models/crop_type.dart';
import 'models/tile.dart';
import 'models/tile_state.dart';

class TileComponent extends RectangleComponent
    with HasGameRef, TapCallbacks {
  final Tile tile;
  final int row;
  final int col;
  final VoidCallback onTap;
  final ui.Image emptyTileImage;
  final TileFarmGame game;

  TileComponent({
    required this.tile,
    required this.row,
    required this.col,
    required this.onTap,
    required this.emptyTileImage,
    required this.game,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.transparent, // 타일 배경 투명하게
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 빈 타일일 때 빈 재배기 이미지 표시
    if (tile.state == TileState.empty) {
      final srcRect = Rect.fromLTWH(0, 0, emptyTileImage.width.toDouble(), emptyTileImage.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawImageRect(
        emptyTileImage,
        srcRect,
        dstRect,
        Paint(),
      );
      return;
    }

    // 작물이 심어진 경우 성장 단계별 이미지 표시
    if (tile.cropType != null) {
      final cropImage = game.getCropImage(tile.cropType!, tile.state);
      if (cropImage != null) {
        final srcRect = Rect.fromLTWH(0, 0, cropImage.width.toDouble(), cropImage.height.toDouble());
        final dstRect = Rect.fromLTWH(0, 0, size.x, size.y);
        canvas.drawImageRect(
          cropImage,
          srcRect,
          dstRect,
          Paint(),
        );
        
        // 디버깅 정보: 상태와 경과 시간 표시 (가장 위 레이어에 표시)
        final stateName = tile.getStateName();
        final elapsedTime = tile.getElapsedTimeText();
        final debugText = '$stateName\n경과: $elapsedTime';
        
        // 텍스트 크기 계산
        final debugTextPainter = TextPainter(
          text: TextSpan(
            text: debugText,
            style: TextStyle(
              color: Colors.yellow,
              fontSize: size.y * 0.08,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        debugTextPainter.layout(maxWidth: size.x);
        
        // 반투명 배경 추가 (가독성 향상)
        final textHeight = debugTextPainter.height;
        final textWidth = debugTextPainter.width;
        final padding = 4.0;
        final bgRect = Rect.fromLTWH(
          (size.x - textWidth) / 2 - padding,
          2, // 상단에서 2픽셀 아래
          textWidth + padding * 2,
          textHeight + padding * 2,
        );
        final bgPaint = Paint()
          ..color = Colors.black.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, Radius.circular(4)),
          bgPaint,
        );
        
        // 텍스트를 배경 위에 그리기 (최상단 레이어)
        debugTextPainter.paint(
          canvas,
          Offset(
            (size.x - textWidth) / 2,
            2 + padding, // 상단에 배치
          ),
        );
        return;
      }
    }

    // 이미지가 없으면 기본 색상과 텍스트로 표시 (폴백)
    Color backgroundColor = Colors.brown.shade300;
    String text = '';
    
    switch (tile.state) {
      case TileState.empty:
        return; // 이미 처리됨
      case TileState.seed:
      case TileState.sprout:
      case TileState.seedling:
      case TileState.youngplant:
        backgroundColor = Colors.green.shade400;
        if (tile.cropType != null) {
          text = '${tile.cropType!.name}';
        }
        break;
      case TileState.harvest:
        backgroundColor = Colors.green.shade600;
        if (tile.cropType != null) {
          text = '${tile.cropType!.name}\n수확!';
        }
        break;
    }

    // 폴백: 배경 그리기
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // 텍스트 그리기
    if (text.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size.y * 0.15,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.x);
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    onTap();
    return true;
  }
}
