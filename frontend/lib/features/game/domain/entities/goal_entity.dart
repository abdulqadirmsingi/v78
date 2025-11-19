import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';
import 'package:street_football_rush/core/constants/game_constants.dart';
import 'package:street_football_rush/core/constants/colors.dart';

enum GoalSide { left, right }

class GoalEntity extends RectangleComponent with HasGameRef {
  final GoalSide side;

  GoalEntity({required this.side})
      : super(
          position: Vector2(
            side == GoalSide.left ? 0 : GameConstants.fieldWidth - GameConstants.goalWidth,
            GameConstants.goalOffsetY,
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
    // Draw goal area with transparent fill
    final goalPaint = Paint()
      ..color = GameColors.goal.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      goalPaint,
    );
    
    // Draw goal posts (thicker borders)
    final postPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // Draw the goal frame
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      postPaint,
    );
    
    // Draw net pattern
    final netPaint = Paint()
      ..color = GameColors.fieldLineWhite.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Horizontal lines for net
    for (double y = 15; y < size.y; y += 15) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        netPaint,
      );
    }
    
    // Vertical lines for net (if goal is wide enough)
    if (size.x > 10) {
      for (double x = 10; x < size.x; x += 10) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.y),
          netPaint,
        );
      }
    }
    
    // Draw goal indicator line extending into field
    final indicatorPaint = Paint()
      ..color = GameColors.goal.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    if (side == GoalSide.left) {
      canvas.drawLine(
        Offset(size.x, size.y / 2),
        Offset(size.x + 30, size.y / 2),
        indicatorPaint,
      );
    } else {
      canvas.drawLine(
        Offset(0, size.y / 2),
        Offset(-30, size.y / 2),
        indicatorPaint,
      );
    }
  }
  
  /// Check if ball is in goal
  bool isBallInGoal(Vector2 ballPosition) {
    return ballPosition.x >= position.x &&
           ballPosition.x <= position.x + size.x &&
           ballPosition.y >= position.y &&
           ballPosition.y <= position.y + size.y;
  }
}

