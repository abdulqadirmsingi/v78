import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';
import 'package:street_football_rush/core/constants/game_constants.dart';
import 'package:street_football_rush/core/constants/colors.dart';

class GoalEntity extends RectangleComponent with HasGameRef {
  GoalEntity()
      : super(
          position: Vector2(
            (GameConstants.fieldWidth - GameConstants.goalWidth) / 2,
            GameConstants.goalY,
          ),
          size: Vector2(GameConstants.goalWidth, GameConstants.goalHeight),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.topLeft,
    ));
  }

  @override
  void render(Canvas canvas) {
    // Draw goal area
    final goalPaint = Paint()
      ..color = GameColors.goal.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      goalPaint,
    );
    
    // Draw goal border
    final borderPaint = Paint()
      ..color = GameColors.goal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
    
    // Draw net pattern
    final netPaint = Paint()
      ..color = GameColors.fieldLineWhite.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Vertical lines
    for (double x = 20; x < size.x; x += 20) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.y),
        netPaint,
      );
    }
    
    // Horizontal lines
    for (double y = 10; y < size.y; y += 10) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        netPaint,
      );
    }
    
    // Draw "GOAL" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'GOAL',
        style: TextStyle(
          color: GameColors.goal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}

