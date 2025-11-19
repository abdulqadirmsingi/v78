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

class _GameOverDialogState extends State<GameOverDialog> with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final LeaderboardApi _api = LeaderboardApi();
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _error;
  int? _playerRank;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();

    // Auto-submit if enabled
    if (_storage.getAutoSubmitScore()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _submitScore();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    // Validate player name
    final playerName = _storage.getPlayerName().trim();
    if (playerName.isEmpty) {
      setState(() {
        _error = 'Please set your name in Settings first';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await _api.submitScore(playerName, widget.score);
      
      setState(() {
        _isSubmitting = false;
        _submitted = true;
        _playerRank = result.rank;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final highScore = _storage.getHighScore();
    final isNewHighScore = widget.score >= highScore;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GameColors.accent, width: 3),
            boxShadow: [
              BoxShadow(
                color: GameColors.accent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNewHighScore ? Icons.emoji_events : Icons.cancel,
                size: 80,
                color: isNewHighScore ? GameColors.goal : GameColors.buttonDanger,
              ),
              const SizedBox(height: 16),
              Text(
                isNewHighScore ? 'NEW RECORD!' : 'GAME OVER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isNewHighScore ? GameColors.goal : GameColors.textLight,
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
                  border: Border.all(
                    color: isNewHighScore ? GameColors.goal : GameColors.accent,
                    width: 2,
                  ),
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
                    if (_playerRank != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.leaderboard,
                              color: GameColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rank: #$_playerRank',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: GameColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (isNewHighScore && _playerRank == null) ...[
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameColors.buttonSuccess.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: GameColors.buttonSuccess),
                        SizedBox(width: 8),
                        Text(
                          'Score submitted!',
                          style: TextStyle(
                            color: GameColors.buttonSuccess,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameColors.buttonDanger.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: GameColors.buttonDanger,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _submitScore,
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              color: GameColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

