import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:street_football_rush/core/constants/game_constants.dart';

class BallEntity extends CircleComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  double friction = 0.98;
  String? lastTouchedBy; // 'player' or 'ai'

  BallEntity({
    required Vector2 position,
  }) : super(
          position: position,
          radius: GameConstants.ballRadius,
          anchor: Anchor.center,
        );

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
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(3, 3), radius, shadowPaint);

    // Draw ball with classic soccer pattern
    final ballPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, ballPaint);

    // Draw black pentagons for soccer ball pattern
    final pentagonPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Simple pentagon pattern - center pentagon
    _drawPentagon(canvas, Offset.zero, radius * 0.4, pentagonPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    // Add shine effect
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.3, -radius * 0.3), radius * 0.25, shinePaint);

    canvas.restore();
  }

  void _drawPentagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const numSides = 5;
    const angleStep = (3.14159 * 2) / numSides;

    for (int i = 0; i < numSides; i++) {
      final angle = i * angleStep - 3.14159 / 2;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply velocity to position
    position += velocity * dt;

    // Apply friction
    velocity *= friction;

    // Stop if velocity is very small
    if (velocity.length < 0.5) {
      velocity = Vector2.zero();
    }

    // Keep ball within field bounds
    _clampToBounds();
  }

  /// Kick the ball in a direction
  void kick(Vector2 direction, double power, String kickedBy) {
    velocity = direction.normalized() * power;
    lastTouchedBy = kickedBy;
  }

  /// Keep ball within field bounds
  void _clampToBounds() {
    // Bounce off left/right walls (excluding goal areas)
    if (position.x - radius < 0) {
      position.x = radius;
      velocity.x = -velocity.x * 0.8; // Bounce with energy loss
    } else if (position.x + radius > GameConstants.fieldWidth) {
      position.x = GameConstants.fieldWidth - radius;
      velocity.x = -velocity.x * 0.8;
    }

    // Bounce off top/bottom walls
    if (position.y - radius < 0) {
      position.y = radius;
      velocity.y = -velocity.y * 0.8;
    } else if (position.y + radius > GameConstants.fieldHeight) {
      position.y = GameConstants.fieldHeight - radius;
      velocity.y = -velocity.y * 0.8;
    }
  }

  /// Reset ball to center
  void reset() {
    position = Vector2(
      GameConstants.fieldWidth / 2,
      GameConstants.fieldHeight / 2,
    );
    velocity = Vector2.zero();
    lastTouchedBy = null;
  }
}

