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
import 'package:street_football_rush/features/game/domain/entities/player_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/defender_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/goal_entity.dart';
import 'package:street_football_rush/features/game/domain/entities/power_up_entity.dart';

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

  final Function(int score) onScoreChanged;
  final Function(int finalScore) onGameOver;
  final Function() onPause;

  // Game state
  GameState gameState = GameState.playing;
  int score = 0;
  int currentDefenderCount = GameConstants.initialDefenders;
  double currentDefenderSpeed = GameConstants.defenderSpeedBase;

  // Entities
  late PlayerEntity player;
  late GoalEntity goal;
  final List<DefenderEntity> defenders = [];
  PowerUpEntity? activePowerUp;

  // Services
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();
  final Random _random = Random();

  // Joystick
  Vector2 joystickDirection = Vector2.zero();
  late JoystickComponent joystick;

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

    // Create goal
    goal = GoalEntity();
    add(goal);

    // Create player
    player = PlayerEntity(
      position: Vector2(
        GameConstants.fieldWidth / 2,
        GameConstants.fieldHeight - 100,
      ),
    );
    add(player);

    // Create initial defenders
    _spawnDefenders(currentDefenderCount);

    // Create joystick
    _createJoystick();

    // Create pause button
    _createPauseButton();
  }

  void _createJoystick() {
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: GameConstants.joystickKnobSize / 2,
        paint: Paint()..color = GameColors.primary.withOpacity(0.8),
      ),
      background: CircleComponent(
        radius: GameConstants.joystickSize / 2,
        paint: Paint()..color = GameColors.background.withOpacity(0.5),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);
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

    // Update player movement from joystick
    if (!joystick.delta.isZero()) {
      joystickDirection = joystick.relativeDelta;
      player.move(joystickDirection, dt);
    }

    // Update defender AI
    for (final defender in defenders) {
      defender.updateAI(player.position, dt);
    }

    // Check collisions
    _checkCollisions();
  }

  void _checkCollisions() {
    // Check player-goal collision
    if (_circleRectCollision(
      player.position,
      player.radius,
      goal.position,
      goal.size,
    )) {
      _onGoalScored();
    }

    // Check player-defender collision
    for (final defender in defenders) {
      if (player.position.distanceTo(defender.position) <
          player.radius + defender.radius) {
        _onCollisionWithDefender();
        return;
      }
    }

    // Check player-powerup collision
    if (activePowerUp != null) {
      if (player.position.distanceTo(activePowerUp!.position) <
          player.radius + activePowerUp!.radius) {
        _onPowerUpCollected();
      }
    }
  }

  bool _circleRectCollision(
    Vector2 circlePos,
    double circleRadius,
    Vector2 rectPos,
    Vector2 rectSize,
  ) {
    final closestX = circlePos.x.clamp(rectPos.x, rectPos.x + rectSize.x);
    final closestY = circlePos.y.clamp(rectPos.y, rectPos.y + rectSize.y);
    final distance = Vector2(closestX, closestY).distanceTo(circlePos);
    return distance < circleRadius;
  }

  void _onGoalScored() {
    score++;
    onScoreChanged(score);

    // Play effects
    _audioService.playSfx(AudioConstants.goalSound);
    _vibrationService.success();

    // Show score popup
    _showScorePopup();

    // Increase difficulty
    _increaseDifficulty();

    // Spawn power-up randomly
    if (_random.nextDouble() < GameConstants.powerUpSpawnChance) {
      _spawnPowerUp();
    }

    // Reset player position
    player.reset();
  }

  void _onCollisionWithDefender() {
    gameState = GameState.gameOver;

    // Play effects
    _audioService.playSfx(AudioConstants.collisionSound);
    _vibrationService.heavy();

    // Trigger game over callback
    onGameOver(score);
  }

  void _onPowerUpCollected() {
    if (activePowerUp == null) return;

    // Apply power-up effect
    player.activateSpeedBoost();

    // Play effects
    _audioService.playSfx(AudioConstants.powerUpSound);
    _vibrationService.light();

    // Remove power-up
    activePowerUp!.removeFromParent();
    activePowerUp = null;
  }

  void _increaseDifficulty() {
    // Increase defender count (up to max)
    if (currentDefenderCount < GameConstants.maxDefenders) {
      currentDefenderCount++;
      _spawnDefenders(1);
    }

    // Increase defender speed
    currentDefenderSpeed *= GameConstants.difficultySpeedMultiplier;
    
    // Note: Existing defenders continue with their current speed
    // New defenders will spawn with the updated speed
  }

  void _spawnDefenders(int count) {
    for (int i = 0; i < count; i++) {
      final defender = DefenderEntity(
        position: _getRandomDefenderPosition(),
        baseSpeed: currentDefenderSpeed,
      );
      defenders.add(defender);
      add(defender);
    }
  }

  Vector2 _getRandomDefenderPosition() {
    return Vector2(
      _random.nextDouble() * (GameConstants.fieldWidth - 100) + 50,
      _random.nextDouble() * (GameConstants.fieldHeight / 2) +
          GameConstants.goalY +
          GameConstants.goalHeight +
          50,
    );
  }

  void _spawnPowerUp() {
    // Remove existing power-up if any
    activePowerUp?.removeFromParent();

    // Spawn new power-up at random position
    activePowerUp = PowerUpEntity(
      position: Vector2(
        _random.nextDouble() * (GameConstants.fieldWidth - 100) + 50,
        _random.nextDouble() * (GameConstants.fieldHeight - 300) + 150,
      ),
    );
    add(activePowerUp!);
  }

  void _showScorePopup() {
    final popup = _ScorePopup(score: score);
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
    score = 0;
    currentDefenderCount = GameConstants.initialDefenders;
    currentDefenderSpeed = GameConstants.defenderSpeedBase;

    // Remove all defenders
    for (final defender in defenders) {
      defender.removeFromParent();
    }
    defenders.clear();

    // Remove power-up
    activePowerUp?.removeFromParent();
    activePowerUp = null;

    // Reset player
    player.reset();

    // Spawn initial defenders
    _spawnDefenders(currentDefenderCount);

    // Resume game
    gameState = GameState.playing;
    resumeEngine();

    onScoreChanged(score);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Alternative drag-based movement (optional)
    // Can be used if joystick is disabled
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
      Offset(0, GameConstants.fieldHeight / 2),
      Offset(GameConstants.fieldWidth, GameConstants.fieldHeight / 2),
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
  final int score;
  double lifetime = 0;
  static const double duration = 1.5;

  _ScorePopup({required this.score})
      : super(
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
    final scale = 1.0 + progress * 0.5;

    canvas.save();
    canvas.scale(scale);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '+1 GOAL!',
        style: TextStyle(
          color: GameColors.goal.withOpacity(opacity),
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(opacity * 0.5),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
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
    position.y -= 50 * dt;

    if (lifetime >= duration) {
      removeFromParent();
    }
  }
}

