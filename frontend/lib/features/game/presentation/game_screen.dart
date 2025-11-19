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

class _GameScreenState extends State<GameScreen> {
  late StreetFootballGame _game;
  int _currentScore = 0;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = StreetFootballGame(
      onScoreChanged: (score) {
        setState(() {
          _currentScore = score;
        });
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
            // Score Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: GameColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: GameColors.goal,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SCORE:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GameColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_currentScore',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: GameColors.accent,
                    ),
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

