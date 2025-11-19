import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/game/presentation/game_screen.dart';
import 'package:street_football_rush/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:street_football_rush/features/menu/presentation/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _audio.playMusic();
  }

  Future<void> _loadHighScore() async {
    final score = _storage.getHighScore();
    setState(() {
      _highScore = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'STREET FOOTBALL',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textLight,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'RUSH',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: GameColors.accent,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 60),

                // High Score
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
                        'HIGH SCORE',
                        style: TextStyle(
                          fontSize: 18,
                          color: GameColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_highScore',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: GameColors.goal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Play Button
                _MenuButton(
                  text: 'PLAY',
                  icon: Icons.play_arrow,
                  color: GameColors.buttonSuccess,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ).then((_) => _loadHighScore());
                  },
                ),
                const SizedBox(height: 16),

                // Leaderboard Button
                _MenuButton(
                  text: 'LEADERBOARD',
                  icon: Icons.leaderboard,
                  color: GameColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Settings Button
                _MenuButton(
                  text: 'SETTINGS',
                  icon: Icons.settings,
                  color: GameColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: GameColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
