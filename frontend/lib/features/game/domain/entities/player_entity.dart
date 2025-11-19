import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/painting.dart';
import 'package:street_football_rush/core/constants/game_constants.dart';
import 'package:street_football_rush/core/constants/colors.dart';

class PlayerEntity extends CircleComponent with HasGameRef {
  final double speed;
  bool hasSpeedBoost = false;
  double speedBoostTimer = 0;

  PlayerEntity({
    required Vector2 position,
    this.speed = GameConstants.playerSpeed,
  }) : super(
          position: position,
          radius: GameConstants.playerRadius,
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
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(2, 2), radius, shadowPaint);
    
    // Draw player circle with gradient effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.player.withOpacity(0.8),
          GameColors.player,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    
    canvas.drawCircle(Offset.zero, radius, gradientPaint);
    
    // Draw border with glow
    final borderPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(Offset.zero, radius, borderPaint);
    
    // Draw inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.3, -radius * 0.3), radius * 0.3, highlightPaint);
    
    // Draw direction indicator (arrow)
    final arrowPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path()
      ..moveTo(0, -radius * 0.7)
      ..lineTo(-5, -radius * 0.4)
      ..lineTo(5, -radius * 0.4)
      ..close();
    
    canvas.drawPath(arrowPath, arrowPaint);
    
    // Draw speed boost indicator with pulsing effect
    if (hasSpeedBoost) {
      final pulseRadius = radius + 5 + (speedBoostTimer % 0.5) * 10;
      
      final boostPaint = Paint()
        ..color = GameColors.powerUp.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(Offset.zero, pulseRadius, boostPaint);
      
      // Inner ring
      final innerBoostPaint = Paint()
        ..color = GameColors.powerUp.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(Offset.zero, radius + 2, innerBoostPaint);
    }
    
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update speed boost timer
    if (hasSpeedBoost) {
      speedBoostTimer -= dt;
      if (speedBoostTimer <= 0) {
        hasSpeedBoost = false;
        speedBoostTimer = 0;
      }
    }
  }

  /// Move player based on joystick input
  void move(Vector2 direction, double dt) {
    if (direction.length > 0) {
      final effectiveSpeed = hasSpeedBoost 
          ? speed * GameConstants.speedBoostMultiplier 
          : speed;
      
      position += direction.normalized() * effectiveSpeed * dt;
      
      // Keep player within bounds
      position.x = position.x.clamp(
        radius,
        GameConstants.fieldWidth - radius,
      );
      position.y = position.y.clamp(
        radius,
        GameConstants.fieldHeight - radius,
      );
    }
  }

  /// Activate speed boost power-up
  void activateSpeedBoost() {
    hasSpeedBoost = true;
    speedBoostTimer = GameConstants.powerUpDuration;
  }

  /// Reset player to starting position
  void reset() {
    position = Vector2(
      GameConstants.fieldWidth / 2,
      GameConstants.fieldHeight - 100,
    );
    hasSpeedBoost = false;
    speedBoostTimer = 0;
  }
}

