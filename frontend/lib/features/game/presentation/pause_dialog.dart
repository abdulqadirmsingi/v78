import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
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
              Icons.pause_circle,
              size: 80,
              color: GameColors.accent,
            ),
            const SizedBox(height: 16),
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: GameColors.textLight,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),

            // Resume Button
            _DialogButton(
              text: 'RESUME',
              icon: Icons.play_arrow,
              color: GameColors.buttonSuccess,
              onPressed: onResume,
            ),
            const SizedBox(height: 12),

            // Restart Button
            _DialogButton(
              text: 'RESTART',
              icon: Icons.refresh,
              color: GameColors.primary,
              onPressed: onRestart,
            ),
            const SizedBox(height: 12),

            // Home Button
            _DialogButton(
              text: 'HOME',
              icon: Icons.home,
              color: GameColors.buttonDanger,
              onPressed: onHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _DialogButton({
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

