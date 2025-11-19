import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:street_football_rush/core/constants/game_constants.dart';
import 'package:street_football_rush/core/constants/colors.dart';

enum DefenderState { patrol, chase }

class DefenderEntity extends CircleComponent with HasGameRef {
  final double baseSpeed;
  final Random _random = Random();

  DefenderState state = DefenderState.patrol;
  Vector2 patrolTarget = Vector2.zero();
  double patrolTimer = 0;
  double chaseDistance = GameConstants.defenderChaseDistance;

  DefenderEntity({
    required Vector2 position,
    this.baseSpeed = GameConstants.defenderSpeedBase,
  }) : super(
         position: position,
         radius: GameConstants.defenderRadius,
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add collision detection
    add(CircleHitbox(radius: radius, anchor: Anchor.center));

    // Set initial patrol target
    _setNewPatrolTarget();
  }

  @override
  void render(Canvas canvas) {
    // Choose color based on state
    final color = state == DefenderState.chase
        ? GameColors.defenderChasing
        : GameColors.defender;

    // Draw defender circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    // Draw "angry" indicator when chasing
    if (state == DefenderState.chase) {
      final alertPaint = Paint()
        ..color = GameColors.fieldLineWhite
        ..style = PaintingStyle.fill;

      // Draw exclamation mark
      canvas.drawCircle(Offset(0, -radius - 8), 2, alertPaint);
      canvas.drawRect(Rect.fromLTWH(-1, -radius - 18, 2, 8), alertPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    patrolTimer -= dt;
  }

  /// Update AI behavior based on player position
  void updateAI(Vector2 playerPosition, double dt) {
    final distanceToPlayer = position.distanceTo(playerPosition);

    // State transition logic
    if (distanceToPlayer < chaseDistance) {
      state = DefenderState.chase;
    } else if (state == DefenderState.chase &&
        distanceToPlayer > chaseDistance * 1.5) {
      // Add hysteresis to prevent rapid state changes
      state = DefenderState.patrol;
      _setNewPatrolTarget();
    }

    // Execute behavior based on state
    switch (state) {
      case DefenderState.patrol:
        _patrol(dt);
        break;
      case DefenderState.chase:
        _chase(playerPosition, dt);
        break;
    }
  }

  /// Patrol behavior - move to random points
  void _patrol(double dt) {
    if (patrolTimer <= 0) {
      _setNewPatrolTarget();
    }

    final direction = (patrolTarget - position).normalized();
    position += direction * baseSpeed * 0.7 * dt; // Slower when patrolling

    // Check if reached patrol target
    if (position.distanceTo(patrolTarget) < 20) {
      _setNewPatrolTarget();
    }

    // Keep within bounds
    _clampToBounds();
  }

  /// Chase behavior - move toward player with prediction
  void _chase(Vector2 playerPosition, double dt) {
    // Simple prediction: aim slightly ahead of player
    final direction = (playerPosition - position).normalized();

    // Add some prediction based on current direction
    final predictedPosition = playerPosition + (direction * 50);
    final chaseDirection = (predictedPosition - position).normalized();

    position += chaseDirection * baseSpeed * dt;

    // Keep within bounds
    _clampToBounds();
  }

  /// Set a new random patrol target
  void _setNewPatrolTarget() {
    patrolTarget = Vector2(
      _random.nextDouble() * (GameConstants.fieldWidth - 100) + 50,
      _random.nextDouble() * (GameConstants.fieldHeight - 200) + 100,
    );
    patrolTimer = 2.0 + _random.nextDouble() * 3.0; // 2-5 seconds
  }

  /// Keep defender within field bounds
  void _clampToBounds() {
    position.x = position.x.clamp(radius, GameConstants.fieldWidth - radius);
    position.y = position.y.clamp(
      radius + GameConstants.goalY + GameConstants.goalHeight,
      GameConstants.fieldHeight - radius,
    );
  }

  /// Increase defender speed (difficulty scaling)
  double get speed => baseSpeed;
}
