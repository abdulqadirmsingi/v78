import 'dart:math';
import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:street_football_rush/core/constants/game_constants.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/constants/audio_constants.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/vibration_service.dart';
import 'package:street_football_rush/features/game/domain/entities/team_player_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/goal_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/ball_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/referee_entity.dart';

enum GameState {
  playing,
  paused,
  gameOver,
}

class StreetFootballGame extends FlameGame
    with HasCollisionDetection, PanDetector {
  StreetFootballGame({
    required this.onScoreChanged,
    required this.onGameOver,
    required this.onPause,
  });

  final Function(int playerScore, int aiScore) onScoreChanged;
  final Function(int finalScore) onGameOver;
  final Function() onPause;

  // Game state
  GameState gameState = GameState.playing;
  int playerScore = 0;
  int aiScore = 0;
  double currentDifficulty = 1.0;

  // Entities
  final List<TeamPlayerEntity> playerTeam = [];
  final List<TeamPlayerEntity> aiTeam = [];
  late TeamPlayerEntity controlledPlayer;
  late BallEntity ball;
  late RefereeEntity referee;
  late GoalEntity leftGoal;
  late GoalEntity rightGoal;

  // Services
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

  // Joystick
  Vector2 joystickDirection = Vector2.zero();
  late JoystickComponent joystick;

  // Ball control
  double kickCooldown = 0;
  static const double kickCooldownTime = 0.3;
  
  // Action buttons state
  bool isShootPressed = false;
  bool isDefendPressed = false;

  @override
  Color backgroundColor() => GameColors.fieldGreen;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set camera viewport to match game dimensions
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(GameConstants.fieldWidth, GameConstants.fieldHeight),
    );

    // Create field
    add(_FieldComponent());

    // Create goals
    leftGoal = GoalEntity(side: GoalSide.left);
    rightGoal = GoalEntity(side: GoalSide.right);
    add(leftGoal);
    add(rightGoal);

    // Create ball at center
    ball = BallEntity(
      position: Vector2(
        GameConstants.fieldWidth / 2,
        GameConstants.fieldHeight / 2,
      ),
    );
    add(ball);

    // Create referee
    referee = RefereeEntity(
      position: Vector2(
        GameConstants.fieldWidth / 2,
        GameConstants.fieldHeight / 2 + 80,
      ),
    );
    add(referee);

    // Create teams
    _createPlayerTeam();
    _createAITeam();

    // Create joystick
    _createJoystick();

    // Create action buttons
    _createActionButtons();

    // Create pause button
    _createPauseButton();
  }

  void _createPlayerTeam() {
    // Player team (Blue) - Right side
    final formations = _getFormation(TeamSide.player);

    for (int i = 0; i < GameConstants.playersPerTeam; i++) {
      final player = TeamPlayerEntity(
        position: formations[i],
        team: TeamSide.player,
        role: _getRole(i),
        playerNumber: i + 1,
        teamColor: Colors.blue,
        speed: GameConstants.playerSpeed,
        isControlled: i == 2, // Midfielder is controlled
      );

      playerTeam.add(player);
      add(player);

      if (i == 2) {
        controlledPlayer = player;
      }
    }
  }

  void _createAITeam() {
    // AI team (Red) - Left side
    final formations = _getFormation(TeamSide.ai);

    for (int i = 0; i < GameConstants.playersPerTeam; i++) {
      final player = TeamPlayerEntity(
        position: formations[i],
        team: TeamSide.ai,
        role: _getRole(i),
        playerNumber: i + 1,
        teamColor: Colors.red,
        speed: GameConstants.aiPlayerSpeedBase * currentDifficulty,
        isControlled: false,
      );

      aiTeam.add(player);
      add(player);
    }
  }

  PlayerRole _getRole(int index) {
    switch (index) {
      case 0:
        return PlayerRole.goalkeeper;
      case 1:
      case 2:
        return PlayerRole.defender;
      case 3:
        return PlayerRole.midfielder;
      case 4:
        return PlayerRole.forward;
      default:
        return PlayerRole.midfielder;
    }
  }

  List<Vector2> _getFormation(TeamSide team) {
    final isPlayerTeam = team == TeamSide.player;
    final baseX = isPlayerTeam
        ? GameConstants.fieldWidth * 0.75
        : GameConstants.fieldWidth * 0.25;

    return [
      // Goalkeeper
      Vector2(
        isPlayerTeam ? GameConstants.fieldWidth - 80 : 80,
        GameConstants.fieldHeight / 2,
      ),
      // Defender 1
      Vector2(
        baseX + (isPlayerTeam ? -50 : 50),
        GameConstants.fieldHeight * 0.3,
      ),
      // Defender 2
      Vector2(
        baseX + (isPlayerTeam ? -50 : 50),
        GameConstants.fieldHeight * 0.7,
      ),
      // Midfielder
      Vector2(
        baseX + (isPlayerTeam ? -150 : 150),
        GameConstants.fieldHeight / 2,
      ),
      // Forward
      Vector2(
        baseX + (isPlayerTeam ? -250 : 250),
        GameConstants.fieldHeight / 2,
      ),
    ];
  }

  void _createJoystick() {
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: GameConstants.joystickKnobSize / 2,
        paint: Paint()..color = GameColors.primary.withOpacity(0.9),
      ),
      background: CircleComponent(
        radius: GameConstants.joystickSize / 2,
        paint: Paint()..color = GameColors.background.withOpacity(0.6),
      ),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );
    add(joystick);
  }

  void _createActionButtons() {
    // Shoot button (top right action button)
    final shootButton = _ActionButton(
      icon: Icons.sports_soccer,
      color: Colors.green,
      position: Vector2(
        GameConstants.fieldWidth - 90,
        GameConstants.fieldHeight - 160,
      ),
      onPressed: () => isShootPressed = true,
      onReleased: () => isShootPressed = false,
      label: 'SHOOT',
    );
    add(shootButton);

    // Defend/Tackle button (bottom right action button)
    final defendButton = _ActionButton(
      icon: Icons.shield,
      color: Colors.orange,
      position: Vector2(
        GameConstants.fieldWidth - 90,
        GameConstants.fieldHeight - 80,
      ),
      onPressed: () => isDefendPressed = true,
      onReleased: () => isDefendPressed = false,
      label: 'DEFEND',
    );
    add(defendButton);
  }

  void _createPauseButton() {
    final pauseButton = _PauseButton(
      onPressed: () {
        pauseGame();
        onPause();
      },
    );
    add(pauseButton);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) return;

    // Update kick cooldown
    if (kickCooldown > 0) {
      kickCooldown -= dt;
    }

    // Update controlled player movement from joystick
    if (!joystick.delta.isZero()) {
      joystickDirection = joystick.relativeDelta;
      controlledPlayer.move(joystickDirection, dt);
    }

    // Update AI players with better coordination
    for (final aiPlayer in aiTeam) {
      aiPlayer.chaseBall(ball.position, ball.velocity, aiTeam, dt);
    }

    // Update non-controlled player team members with coordination
    for (final player in playerTeam) {
      if (!player.isControlled) {
        player.chaseBall(ball.position, ball.velocity, playerTeam, dt);
      }
    }

    // Update referee to follow ball
    referee.followBall(ball.position);

    // Check ball interactions
    _checkBallInteractions();

    // Check goals
    _checkGoals();
  }

  void _checkBallInteractions() {
    // Check controlled player actions
    if (controlledPlayer.canReachBall(ball.position) && kickCooldown <= 0) {
      if (isShootPressed) {
        // Power shot toward goal
        final kickDirection = controlledPlayer.getKickDirection(ball.position);
        ball.kick(kickDirection, GameConstants.ballSpeed * GameConstants.shootPowerMultiplier, 'player');
        kickCooldown = kickCooldownTime;
        _audioService.playSfx(AudioConstants.kickSound);
        _vibrationService.light();
        isShootPressed = false;
      } else if (!joystick.delta.isZero()) {
        // Normal kick in movement direction
        ball.kick(joystickDirection.normalized(), GameConstants.ballSpeed, 'player');
        kickCooldown = kickCooldownTime;
        _audioService.playSfx(AudioConstants.kickSound);
      }
    }

    // Defend/Tackle button - steal ball from nearby opponent
    if (isDefendPressed && kickCooldown <= 0) {
      for (final aiPlayer in aiTeam) {
        final distanceToOpponent = controlledPlayer.position.distanceTo(aiPlayer.position);
        if (distanceToOpponent < GameConstants.tackleDistance) {
          final distanceToBall = aiPlayer.position.distanceTo(ball.position);
          if (distanceToBall < 30) {
            // Successful tackle - kick ball away from opponent
            final tackleDirection = (controlledPlayer.position - aiPlayer.position).normalized();
            ball.kick(tackleDirection, GameConstants.ballSpeed * 0.8, 'player');
            kickCooldown = kickCooldownTime * 0.5;
            _audioService.playSfx(AudioConstants.collisionSound);
            _vibrationService.light();
            break;
          }
        }
      }
      isDefendPressed = false;
    }

    // AI players kick with intelligence
    for (final aiPlayer in aiTeam) {
      if (aiPlayer.canReachBall(ball.position) && kickCooldown <= 0) {
        // AI decides to shoot or pass
        if (aiPlayer.aiDecisionTimer <= 0) {
          final distanceToGoal = aiPlayer.position.distanceTo(
            Vector2(GameConstants.fieldWidth, GameConstants.fieldHeight / 2),
          );
          
          // Shoot if close to goal
          if (distanceToGoal < 250 && aiPlayer.role == PlayerRole.forward) {
            final kickDirection = aiPlayer.getKickDirection(ball.position);
            ball.kick(kickDirection, GameConstants.ballSpeed * 1.5, 'ai');
            kickCooldown = kickCooldownTime;
            _audioService.playSfx(AudioConstants.kickSound);
          } else {
            // Try to pass to better positioned teammate
            final passTarget = aiPlayer.findPassTarget(aiTeam, ball.position);
            if (passTarget != null) {
              final passDirection = (passTarget.position - ball.position).normalized();
              ball.kick(passDirection, GameConstants.ballSpeed * GameConstants.passPowerMultiplier, 'ai');
              kickCooldown = kickCooldownTime * 0.7;
              _audioService.playSfx(AudioConstants.kickSound);
            } else {
              // Just kick toward goal
              final kickDirection = aiPlayer.getKickDirection(ball.position);
              ball.kick(kickDirection, GameConstants.ballSpeed, 'ai');
              kickCooldown = kickCooldownTime;
              _audioService.playSfx(AudioConstants.kickSound);
            }
          }
          
          aiPlayer.aiDecisionTimer = GameConstants.aiReactionTime;
          break;
        }
      }
    }

    // Player team AI members kick
    for (final player in playerTeam) {
      if (!player.isControlled &&
          player.canReachBall(ball.position) &&
          kickCooldown <= 0) {
        
        if (player.aiDecisionTimer <= 0) {
          // Try to pass to controlled player if they're in good position
          final distanceToControlled = player.position.distanceTo(controlledPlayer.position);
          if (distanceToControlled < GameConstants.passDistance &&
              distanceToControlled > 50) {
            final passDirection = (controlledPlayer.position - ball.position).normalized();
            ball.kick(passDirection, GameConstants.ballSpeed * GameConstants.passPowerMultiplier, 'player');
            kickCooldown = kickCooldownTime * 0.7;
          } else {
            // Pass to another teammate or shoot
            final passTarget = player.findPassTarget(playerTeam, ball.position);
            if (passTarget != null) {
              final passDirection = (passTarget.position - ball.position).normalized();
              ball.kick(passDirection, GameConstants.ballSpeed * GameConstants.passPowerMultiplier, 'player');
              kickCooldown = kickCooldownTime * 0.7;
            } else {
              final kickDirection = player.getKickDirection(ball.position);
              ball.kick(kickDirection, GameConstants.ballSpeed, 'player');
              kickCooldown = kickCooldownTime;
            }
          }
          
          _audioService.playSfx(AudioConstants.kickSound);
          player.aiDecisionTimer = GameConstants.aiReactionTime;
          break;
        }
      }
    }
  }

  void _checkGoals() {
    // Check if ball is in left goal (AI's goal - player scores)
    if (leftGoal.isBallInGoal(ball.position)) {
      if (ball.lastTouchedBy == 'player') {
        _onGoalScored(TeamSide.player);
      }
    }

    // Check if ball is in right goal (Player's goal - AI scores)
    if (rightGoal.isBallInGoal(ball.position)) {
      if (ball.lastTouchedBy == 'ai') {
        _onGoalScored(TeamSide.ai);
      }
    }
  }

  void _onGoalScored(TeamSide scorer) {
    if (scorer == TeamSide.player) {
      playerScore++;
    } else {
      aiScore++;
    }

    onScoreChanged(playerScore, aiScore);

    // Play effects
    _audioService.playSfx(AudioConstants.goalSound);
    _vibrationService.success();

    // Show score popup
    _showScorePopup(scorer);

    // Increase difficulty
    _increaseDifficulty();

    // Reset positions
    _resetPositions();
  }

  void _increaseDifficulty() {
    currentDifficulty *= GameConstants.difficultySpeedMultiplier;
    // Difficulty is used when AI players are created
  }

  void _resetPositions() {
    // Reset ball to center
    ball.reset();

    // Reset all players to their home positions
    for (final player in playerTeam) {
      player.returnToPosition();
    }

    for (final aiPlayer in aiTeam) {
      aiPlayer.returnToPosition();
    }

    // Reset referee
    referee.reset();

    // Brief pause
    gameState = GameState.paused;
    Future.delayed(const Duration(seconds: 2), () {
      if (gameState == GameState.paused) {
        gameState = GameState.playing;
      }
    });
  }

  void _showScorePopup(TeamSide scorer) {
    final popup = _ScorePopup(
      scorer: scorer,
      playerScore: playerScore,
      aiScore: aiScore,
    );
    add(popup);
  }

  void pauseGame() {
    gameState = GameState.paused;
    pauseEngine();
  }

  void resumeGame() {
    gameState = GameState.playing;
    resumeEngine();
  }

  void resetGame() {
    playerScore = 0;
    aiScore = 0;
    currentDifficulty = 1.0;

    // Reset all entities
    _resetPositions();

    // Resume game
    gameState = GameState.playing;
    resumeEngine();

    onScoreChanged(playerScore, aiScore);
  }

  // Getter for UI
  int get currentDefenderCount => aiTeam.length;

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Alternative drag-based movement (optional)
  }
}

// Field component to draw the soccer field
class _FieldComponent extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    // Draw field boundaries
    final boundaryPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.lineWidth;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        GameConstants.fieldWidth,
        GameConstants.fieldHeight,
      ),
      boundaryPaint,
    );

    // Draw center line
    canvas.drawLine(
      Offset(GameConstants.fieldWidth / 2, 0),
      Offset(GameConstants.fieldWidth / 2, GameConstants.fieldHeight),
      boundaryPaint,
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(
        GameConstants.fieldWidth / 2,
        GameConstants.fieldHeight / 2,
      ),
      80,
      boundaryPaint,
    );

    // Draw center spot
    final spotPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        GameConstants.fieldWidth / 2,
        GameConstants.fieldHeight / 2,
      ),
      5,
      spotPaint,
    );

    // Draw penalty areas
    _drawPenaltyArea(canvas, true); // Left
    _drawPenaltyArea(canvas, false); // Right
  }

  void _drawPenaltyArea(Canvas canvas, bool isLeft) {
    final paint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.lineWidth;

    final penaltyBoxWidth = 100.0;
    final penaltyBoxHeight = 250.0;
    final x = isLeft ? 0.0 : GameConstants.fieldWidth - penaltyBoxWidth;
    final y = (GameConstants.fieldHeight - penaltyBoxHeight) / 2;

    canvas.drawRect(
      Rect.fromLTWH(x, y, penaltyBoxWidth, penaltyBoxHeight),
      paint,
    );

    // Draw penalty spot
    final spotPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        isLeft ? penaltyBoxWidth / 2 : GameConstants.fieldWidth - penaltyBoxWidth / 2,
        GameConstants.fieldHeight / 2,
      ),
      4,
      spotPaint,
    );
  }
}

// Action button component (Shoot/Defend)
class _ActionButton extends PositionComponent with TapCallbacks {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final String label;
  bool isPressed = false;

  _ActionButton({
    required this.icon,
    required this.color,
    required Vector2 position,
    required this.onPressed,
    required this.onReleased,
    required this.label,
  }) : super(
          position: position,
          size: Vector2(GameConstants.actionButtonSize, GameConstants.actionButtonSize),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final scale = isPressed ? 0.9 : 1.0;
    
    canvas.save();
    canvas.scale(scale);

    // Draw button shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawCircle(Offset(2, 2), size.x / 2, shadowPaint);

    // Draw button background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.7),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.x / 2))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, size.x / 2, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset.zero, size.x / 2, borderPaint);

    // Draw icon (simplified representation)
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (icon == Icons.sports_soccer) {
      // Draw soccer ball icon
      canvas.drawCircle(Offset.zero, 12, iconPaint);
      final blackPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-4, -4), 3, blackPaint);
      canvas.drawCircle(Offset(4, -4), 3, blackPaint);
    } else {
      // Draw shield icon
      final path = Path()
        ..moveTo(0, -15)
        ..lineTo(-10, -10)
        ..lineTo(-10, 5)
        ..lineTo(0, 15)
        ..lineTo(10, 5)
        ..lineTo(10, -10)
        ..close();
      canvas.drawPath(path, iconPaint);
    }

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, size.y / 2 + 5),
    );

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
    onPressed();
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    onReleased();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    onReleased();
  }
}

// Pause button component
class _PauseButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  _PauseButton({required this.onPressed})
      : super(
          position: Vector2(GameConstants.fieldWidth - 60, 20),
          size: Vector2(40, 40),
        );

  @override
  void render(Canvas canvas) {
    // Draw button background
    final bgPaint = Paint()
      ..color = GameColors.background.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      bgPaint,
    );

    // Draw pause icon (two bars)
    final iconPaint = Paint()
      ..color = GameColors.fieldLineWhite
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(12, 10, 5, 20), iconPaint);
    canvas.drawRect(Rect.fromLTWH(23, 10, 5, 20), iconPaint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}

// Score popup animation
class _ScorePopup extends PositionComponent {
  final TeamSide scorer;
  final int playerScore;
  final int aiScore;
  double lifetime = 0;
  static const double duration = 2.0;

  _ScorePopup({
    required this.scorer,
    required this.playerScore,
    required this.aiScore,
  }) : super(
          position: Vector2(
            GameConstants.fieldWidth / 2,
            GameConstants.fieldHeight / 2 - 100,
          ),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final progress = lifetime / duration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 1.0 + progress * 0.3;

    canvas.save();
    canvas.scale(scale);

    final scorerText = scorer == TeamSide.player ? 'PLAYER' : 'AI';
    final color = scorer == TeamSide.player ? Colors.blue : Colors.red;

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'GOAL!\n',
            style: TextStyle(
              color: GameColors.goal.withOpacity(opacity),
              fontSize: 56,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(opacity * 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          TextSpan(
            text: '$scorerText SCORES!\n',
            style: TextStyle(
              color: color.withOpacity(opacity),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: '$playerScore - $aiScore',
            style: TextStyle(
              color: Colors.white.withOpacity(opacity),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime += dt;

    // Move upward
    position.y -= 30 * dt;

    if (lifetime >= duration) {
      removeFromParent();
    }
  }
}
