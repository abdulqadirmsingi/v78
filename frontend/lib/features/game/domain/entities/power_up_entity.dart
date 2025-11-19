import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:street_football_rush/core/constants/colors.dart';

enum PowerUpType {
  speedBoost,
}

class PowerUpEntity extends CircleComponent with HasGameRef {
  final PowerUpType type;
  double animationTimer = 0;

  PowerUpEntity({
    required Vector2 position,
    this.type = PowerUpType.speedBoost,
    double radius = 15,
  }) : super(
          position: position,
          radius: radius,
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
    // Pulsating effect
    final pulseScale = 1.0 + (animationTimer * 0.2);
    final effectiveRadius = radius * pulseScale;
    
    // Draw outer glow
    final glowPaint = Paint()
      ..color = GameColors.powerUp.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, effectiveRadius * 1.5, glowPaint);
    
    // Draw main circle
    final paint = Paint()
      ..color = GameColors.powerUp
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, effectiveRadius, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset.zero, effectiveRadius, borderPaint);
    
    // Draw star shape inside
    _drawStar(canvas, effectiveRadius * 0.6);
  }

  void _drawStar(Canvas canvas, double size) {
    final paint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;
    
    final path = Path();
    const numPoints = 5;
    const angleStep = (3.14159 * 2) / numPoints;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final angle = i * angleStep / 2 - 3.14159 / 2;
      final radius = i.isEven ? size : size * 0.4;
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      
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
    
    // Animate pulsating effect
    animationTimer += dt * 3;
    if (animationTimer > 3.14159 * 2) {
      animationTimer = 0;
    }
  }
}

