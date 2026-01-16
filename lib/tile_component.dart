import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'models/crop_type.dart';
import 'models/tile.dart';
import 'models/tile_state.dart';

class TileComponent extends RectangleComponent
    with HasGameRef, TapCallbacks {
  final Tile tile;
  final int row;
  final int col;
  final VoidCallback onTap;

  TileComponent({
    required this.tile,
    required this.row,
    required this.col,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 타일 배경색
    Color backgroundColor;
    String text = '';

    switch (tile.state) {
      case TileState.empty:
        backgroundColor = Colors.brown.shade300;
        text = '빈 땅';
        break;
      case TileState.planted:
        backgroundColor = Colors.green.shade200;
        text = '심음';
        break;
      case TileState.growing:
        backgroundColor = Colors.green.shade400;
        if (tile.cropType != null) {
          final remainingTime = tile.getRemainingTimeText();
          if (remainingTime != null) {
            text = '${tile.cropType!.name}\n${remainingTime}';
          } else {
            text = '${tile.cropType!.name}\n성장중';
          }
        }
        break;
      case TileState.ready:
        backgroundColor = Colors.green.shade600;
        if (tile.cropType != null) {
          text = '${tile.cropType!.name}\n수확!';
        }
        break;
    }

    // 배경 그리기
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // 테두리 그리기
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
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
