import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
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
    // Draw player circle
    final paint = Paint()
      ..color = GameColors.player
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, radius, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset.zero, radius, borderPaint);
    
    // Draw direction indicator (small dot)
    final dotPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(0, -radius * 0.5), 3, dotPaint);
    
    // Draw speed boost indicator
    if (hasSpeedBoost) {
      final boostPaint = Paint()
        ..color = GameColors.powerUp.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(Offset.zero, radius + 5, boostPaint);
    }
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

