import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/connection_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/game/presentation/game_screen.dart';
import 'package:street_football_rush/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:street_football_rush/features/menu/presentation/settings_screen.dart';
import 'package:street_football_rush/features/leaderboard/data/api/leaderboard_api.dart';
import 'package:street_football_rush/features/leaderboard/data/models/score_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  final ConnectionService _connectionService = ConnectionService();
  final LeaderboardApi _api = LeaderboardApi();
  
  int _highScore = 0;
  List<ScoreModel>? _topScores;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _loadTopScores();
    _audio.playMusic();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final score = _storage.getHighScore();
    setState(() {
      _highScore = score;
    });
  }

  Future<void> _loadTopScores() async {
    try {
      final response = await _api.getLeaderboard(limit: 3);
      if (mounted) {
        setState(() {
          _topScores = response.leaderboard;
        });
      }
    } catch (e) {
      // Silently fail - not critical for home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Connection status
                StreamBuilder<ConnectionStatus>(
                  stream: _connectionService.statusStream,
                  initialData: _connectionService.status,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? ConnectionStatus.unknown;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == ConnectionStatus.connected
                            ? Colors.green.withOpacity(0.2)
                            : status == ConnectionStatus.disconnected
                                ? Colors.red.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: status == ConnectionStatus.connected
                              ? Colors.green
                              : status == ConnectionStatus.disconnected
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status == ConnectionStatus.connected
                                  ? Colors.green
                                  : status == ConnectionStatus.disconnected
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _connectionService.statusText,
                            style: TextStyle(
                              color: GameColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

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
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.1),
                      child: Text(
                        'RUSH',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: GameColors.accent,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: GameColors.accent.withOpacity(
                                _pulseController.value * 0.5,
                              ),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // High Score
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GameColors.primary,
                        GameColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameColors.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.accent.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: GameColors.goal,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'YOUR HIGH SCORE',
                            style: TextStyle(
                              fontSize: 18,
                              color: GameColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                const SizedBox(height: 24),

                // Top 3 Preview
                if (_topScores != null && _topScores!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GameColors.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.leaderboard,
                              color: GameColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TOP PLAYERS',
                              style: TextStyle(
                                fontSize: 14,
                                color: GameColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          _topScores!.length > 3 ? 3 : _topScores!.length,
                          (index) {
                            final score = _topScores![index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: index == 0
                                          ? const Color(0xFFFFD700)
                                          : index == 1
                                              ? const Color(0xFFC0C0C0)
                                              : const Color(0xFFCD7F32),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      score.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: GameColors.textLight,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${score.score}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.goal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Play Button
                _MenuButton(
                  text: 'PLAY',
                  icon: Icons.play_arrow,
                  color: GameColors.buttonSuccess,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ).then((_) {
                      _loadHighScore();
                      _loadTopScores();
                    });
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
                    ).then((_) => _loadTopScores());
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
          shadowColor: color.withOpacity(0.5),
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
