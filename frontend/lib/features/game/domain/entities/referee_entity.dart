import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:street_football_rush/core/constants/game_constants.dart';

class RefereeEntity extends CircleComponent with HasGameRef {
  Vector2 targetPosition = Vector2.zero();
  final double speed = GameConstants.refereeSpeed;

  RefereeEntity({
    required Vector2 position,
  }) : super(
          position: position,
          radius: GameConstants.refereeRadius,
          anchor: Anchor.center,
        ) {
    targetPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add collision detection
    add(CircleHitbox(
      radius: radius,
      anchor: Anchor.center,
    ));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(2, 2), radius, shadowPaint);

    // Draw referee body (black with yellow details)
    final bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, bodyPaint);

    // Draw yellow stripe (referee uniform)
    final stripePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(-radius, -3, radius * 2, 6),
      stripePaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    // Draw whistle (small yellow circle)
    final whistlePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius * 0.5, -radius * 0.3), 3, whistlePaint);

    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move towards target position
    final direction = (targetPosition - position);
    if (direction.length > 5) {
      position += direction.normalized() * speed * dt;
    }

    // Keep referee within field bounds
    _clampToBounds();
  }

  /// Follow the ball position with some offset
  void followBall(Vector2 ballPosition) {
    // Stay slightly behind the ball
    targetPosition = Vector2(
      ballPosition.x.clamp(
        GameConstants.fieldWidth * 0.2,
        GameConstants.fieldWidth * 0.8,
      ),
      GameConstants.fieldHeight / 2,
    );
  }

  /// Keep referee within field bounds
  void _clampToBounds() {
    position.x = position.x.clamp(radius, GameConstants.fieldWidth - radius);
    position.y = position.y.clamp(radius, GameConstants.fieldHeight - radius);
  }

  /// Reset referee position
  void reset() {
    position = Vector2(
      GameConstants.fieldWidth / 2,
      GameConstants.fieldHeight / 2 + 50,
    );
    targetPosition = position.clone();
  }
}

