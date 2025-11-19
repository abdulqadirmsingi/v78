import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:street_football_rush/core/constants/game_constants.dart';

enum TeamSide { player, ai }

enum PlayerRole { goalkeeper, defender, midfielder, forward }

class TeamPlayerEntity extends CircleComponent with HasGameRef {
  final TeamSide team;
  final PlayerRole role;
  final int playerNumber;
  final Color teamColor;
  final double speed;
  bool isControlled; // True if this is the player-controlled character

  Vector2 homePosition = Vector2.zero();
  Vector2 targetPosition = Vector2.zero();
  double reactionTimer = 0;
  double aiDecisionTimer = 0;
  bool isChasing = false;
  TeamPlayerEntity? passTarget;

  TeamPlayerEntity({
    required Vector2 position,
    required this.team,
    required this.role,
    required this.playerNumber,
    required this.teamColor,
    this.speed = GameConstants.aiPlayerSpeedBase,
    this.isControlled = false,
  }) : super(
          position: position,
          radius: GameConstants.aiPlayerRadius,
          anchor: Anchor.center,
        ) {
    homePosition = position.clone();
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
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(2, 2), radius * 0.8, shadowPaint);

    // Stick figure paint
    final stickPaint = Paint()
      ..color = teamColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw head
    canvas.drawCircle(Offset(0, -radius * 0.5), radius * 0.3, stickPaint);

    // Draw body (vertical line)
    canvas.drawLine(
      Offset(0, -radius * 0.2),
      Offset(0, radius * 0.3),
      stickPaint,
    );

    // Draw arms (horizontal line)
    canvas.drawLine(
      Offset(-radius * 0.4, 0),
      Offset(radius * 0.4, 0),
      stickPaint,
    );

    // Draw legs (two lines)
    canvas.drawLine(
      Offset(0, radius * 0.3),
      Offset(-radius * 0.3, radius * 0.7),
      stickPaint,
    );
    canvas.drawLine(
      Offset(0, radius * 0.3),
      Offset(radius * 0.3, radius * 0.7),
      stickPaint,
    );

    // Draw player number on jersey
    final textPainter = TextPainter(
      text: TextSpan(
        text: playerNumber.toString(),
        style: TextStyle(
          color: teamColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 + 3),
    );

    // Draw glow for controlled player
    if (isControlled) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(0, 0), radius, glowPaint);
      
      // Draw arrow above controlled player
      final arrowPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill;

      final arrowPath = Path()
        ..moveTo(0, -radius - 10)
        ..lineTo(-5, -radius - 5)
        ..lineTo(5, -radius - 5)
        ..close();

      canvas.drawPath(arrowPath, arrowPaint);
    }

    // Draw role indicator badge
    final badgeColor = _getRoleColor();
    final badgePaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(radius * 0.5, -radius * 0.5), 4, badgePaint);
    
    // Border for badge
    final badgeBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(Offset(radius * 0.5, -radius * 0.5), 4, badgeBorderPaint);

    canvas.restore();
  }

  Color _getRoleColor() {
    switch (role) {
      case PlayerRole.goalkeeper:
        return Colors.yellow;
      case PlayerRole.defender:
        return Colors.red;
      case PlayerRole.midfielder:
        return Colors.green;
      case PlayerRole.forward:
        return Colors.blue;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isControlled) {
      // AI behavior
      reactionTimer -= dt;
      aiDecisionTimer -= dt;

      // Move towards target position
      final direction = (targetPosition - position);
      if (direction.length > 5) {
        final moveSpeed = isChasing ? speed * 1.1 : speed * 0.8;
        position += direction.normalized() * moveSpeed * dt;
      }
    }

    // Keep player within field bounds
    _clampToBounds();
  }

  /// Manual movement for controlled player
  void move(Vector2 direction, double dt) {
    if (direction.length > 0) {
      position += direction.normalized() * speed * dt;
      _clampToBounds();
    }
  }

  /// AI behavior to chase ball with intelligent positioning
  void chaseBall(Vector2 ballPosition, Vector2 ballVelocity, List<TeamPlayerEntity> teammates, double dt) {
    if (isControlled) return;

    final distanceToBall = position.distanceTo(ballPosition);
    final distanceFromHome = position.distanceTo(homePosition);

    // Predict ball future position
    final predictedBallPos = ballPosition + (ballVelocity * 0.5);

    // Check if teammate is closer to ball
    bool teammateCloser = false;
    for (final teammate in teammates) {
      if (teammate != this && !teammate.isControlled) {
        if (teammate.position.distanceTo(ballPosition) < distanceToBall - 50) {
          teammateCloser = true;
          break;
        }
      }
    }

    // Different behavior based on role
    switch (role) {
      case PlayerRole.goalkeeper:
        // Stay near goal but move laterally to block
        final goalX = team == TeamSide.player ? 50.0 : GameConstants.fieldWidth - 50;
        final targetY = ballPosition.y.clamp(
          GameConstants.goalOffsetY - 20,
          GameConstants.goalOffsetY + GameConstants.goalHeight + 20,
        );
        
        // Move toward ball if it's very close to goal
        if (distanceToBall < 100) {
          targetPosition = ballPosition.clone();
          isChasing = true;
        } else {
          targetPosition = Vector2(goalX, targetY);
          isChasing = false;
        }
        break;

      case PlayerRole.defender:
        // Stay in defensive zone but chase if ball is close or in danger
        final isInDangerZone = team == TeamSide.player
            ? ballPosition.x < GameConstants.fieldWidth * 0.4
            : ballPosition.x > GameConstants.fieldWidth * 0.6;

        if (distanceToBall < 150 && (isInDangerZone || !teammateCloser)) {
          targetPosition = predictedBallPos;
          isChasing = true;
        } else if (distanceFromHome > GameConstants.formationTolerance) {
          targetPosition = homePosition.clone();
          isChasing = false;
        } else {
          targetPosition = _getDefensivePosition(ballPosition);
          isChasing = false;
        }
        break;

      case PlayerRole.midfielder:
        // Balance between attack and defense
        if (distanceToBall < 200 && !teammateCloser) {
          targetPosition = predictedBallPos;
          isChasing = true;
        } else if (distanceFromHome > GameConstants.formationTolerance * 1.5) {
          targetPosition = homePosition.clone();
          isChasing = false;
        } else {
          // Support play by positioning between ball and home
          final supportPos = (ballPosition + homePosition) / 2;
          targetPosition = supportPos;
          isChasing = false;
        }
        break;

      case PlayerRole.forward:
        // Most aggressive, but stay in attacking zone
        final isInAttackingZone = team == TeamSide.player
            ? ballPosition.x > GameConstants.fieldWidth * 0.4
            : ballPosition.x < GameConstants.fieldWidth * 0.6;

        if (distanceToBall < 250 || isInAttackingZone) {
          targetPosition = predictedBallPos;
          isChasing = true;
        } else if (distanceFromHome > GameConstants.formationTolerance * 2) {
          targetPosition = homePosition.clone();
          isChasing = false;
        } else {
          // Position for receiving pass
          final attackPos = team == TeamSide.player
              ? Vector2(GameConstants.fieldWidth * 0.7, GameConstants.fieldHeight / 2)
              : Vector2(GameConstants.fieldWidth * 0.3, GameConstants.fieldHeight / 2);
          targetPosition = attackPos;
          isChasing = false;
        }
        break;
    }
  }

  Vector2 _getDefensivePosition(Vector2 ballPosition) {
    final defensiveX = team == TeamSide.player
        ? homePosition.x.clamp(50.0, GameConstants.fieldWidth * 0.4)
        : homePosition.x.clamp(GameConstants.fieldWidth * 0.6, GameConstants.fieldWidth - 50);

    // Position between ball and goal
    final goalY = GameConstants.fieldHeight / 2;
    final defensiveY = (ballPosition.y + goalY) / 2;

    return Vector2(defensiveX, defensiveY);
  }
  
  /// Find best teammate to pass to
  TeamPlayerEntity? findPassTarget(List<TeamPlayerEntity> teammates, Vector2 ballPosition) {
    TeamPlayerEntity? bestTarget;
    double bestScore = 0;
    
    for (final teammate in teammates) {
      if (teammate == this || teammate.isControlled) continue;
      
      final distance = position.distanceTo(teammate.position);
      if (distance > GameConstants.passDistance || distance < 30) continue;
      
      // Score based on: distance to goal, distance from defender, forward position
      final goalX = team == TeamSide.player ? 0.0 : GameConstants.fieldWidth;
      final distanceToGoal = (Vector2(goalX, GameConstants.fieldHeight / 2) - teammate.position).length;
      final isForward = team == TeamSide.player
          ? teammate.position.x < position.x
          : teammate.position.x > position.x;
      
      final score = (1000 - distanceToGoal) + (isForward ? 200 : 0);
      
      if (score > bestScore) {
        bestScore = score;
        bestTarget = teammate;
      }
    }
    
    return bestTarget;
  }

  /// Return to home position
  void returnToPosition() {
    targetPosition = homePosition.clone();
  }

  /// Keep player within field bounds
  void _clampToBounds() {
    position.x = position.x.clamp(radius, GameConstants.fieldWidth - radius);
    position.y = position.y.clamp(radius, GameConstants.fieldHeight - radius);
  }

  /// Check if player can reach ball
  bool canReachBall(Vector2 ballPosition) {
    return position.distanceTo(ballPosition) < radius + GameConstants.ballRadius + 5;
  }

  /// Get kick direction based on team
  Vector2 getKickDirection(Vector2 ballPosition) {
    // Kick towards opponent's goal
    final goalX = team == TeamSide.player
        ? GameConstants.fieldWidth
        : 0.0;
    
    final goalY = GameConstants.fieldHeight / 2;
    
    return (Vector2(goalX, goalY) - ballPosition).normalized();
  }
}

