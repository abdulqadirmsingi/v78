import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/leaderboard/data/api/leaderboard_api.dart';

class GameOverDialog extends StatefulWidget {
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  final StorageService _storage = StorageService();
  final LeaderboardApi _api = LeaderboardApi();
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _error;

  Future<void> _submitScore() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final playerName = _storage.getPlayerName();
      await _api.submitScore(playerName, widget.score);
      
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Failed to submit score';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final highScore = _storage.getHighScore();
    final isNewHighScore = widget.score >= highScore;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GameColors.accent, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel,
              size: 80,
              color: GameColors.buttonDanger,
            ),
            const SizedBox(height: 16),
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: GameColors.textLight,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),

            // Score Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.primary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameColors.accent, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR SCORE',
                    style: TextStyle(
                      fontSize: 18,
                      color: GameColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: GameColors.goal,
                    ),
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '🏆 NEW HIGH SCORE! 🏆',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GameColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit to Leaderboard
            if (!_submitted && _error == null)
              _SubmitButton(
                isSubmitting: _isSubmitting,
                onSubmit: _submitScore,
              ),
            
            if (_submitted)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: GameColors.buttonSuccess),
                    SizedBox(width: 8),
                    Text(
                      'Score submitted!',
                      style: TextStyle(
                        color: GameColors.buttonSuccess,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: GameColors.buttonDanger,
                  ),
                ),
              ),

            // Restart Button
            _GameOverButton(
              text: 'PLAY AGAIN',
              icon: Icons.refresh,
              color: GameColors.buttonSuccess,
              onPressed: widget.onRestart,
            ),
            const SizedBox(height: 12),

            // Home Button
            _GameOverButton(
              text: 'HOME',
              icon: Icons.home,
              color: GameColors.primary,
              onPressed: widget.onHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.accent,
            foregroundColor: GameColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: GameColors.textLight,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload),
                    SizedBox(width: 8),
                    Text(
                      'SUBMIT TO LEADERBOARD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _GameOverButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: GameColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

