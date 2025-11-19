import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/game/presentation/game_world.dart';
import 'package:street_football_rush/features/game/presentation/game_over_dialog.dart';
import 'package:street_football_rush/features/game/presentation/pause_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late StreetFootballGame _game;
  int _currentScore = 0;
  final StorageService _storage = StorageService();
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreScaleAnimation;

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scoreScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _initGame();
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _initGame() {
    _game = StreetFootballGame(
      onScoreChanged: (score) {
        setState(() {
          _currentScore = score;
        });
        // Animate score change
        _scoreAnimationController.forward(from: 0);
      },
      onGameOver: (finalScore) {
        _handleGameOver(finalScore);
      },
      onPause: () {
        _showPauseDialog();
      },
    );
  }

  void _handleGameOver(int finalScore) {
    // Save high score
    _storage.saveHighScore(finalScore);

    // Show game over dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameOverDialog(
            score: finalScore,
            onRestart: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            onHome: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      }
    });
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseDialog(
        onResume: () {
          Navigator.of(context).pop();
          _game.resumeGame();
        },
        onRestart: () {
          Navigator.of(context).pop();
          _restartGame();
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _currentScore = 0;
      _game.resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Score Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GameColors.primary,
                    GameColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Defender count
                  _InfoChip(
                    icon: Icons.groups,
                    label: '${_game.currentDefenderCount}',
                    color: GameColors.defender,
                  ),
                  
                  // Score
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _scoreScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scoreScaleAnimation.value,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sports_soccer,
                                  color: GameColors.goal,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GameColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: GameColors.accent.withOpacity(0.3),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$_currentScore',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Difficulty level
                  _InfoChip(
                    icon: Icons.speed,
                    label: 'Lv${_currentScore + 1}',
                    color: GameColors.accent,
                  ),
                ],
              ),
            ),

            // Game View
            Expanded(
              child: Container(
                color: GameColors.fieldGreen,
                child: GameWidget(game: _game),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

