import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/features/leaderboard/data/api/leaderboard_api.dart';
import 'package:street_football_rush/features/leaderboard/data/models/score_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardApi _api = LeaderboardApi();
  List<ScoreModel>? _scores;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _api.getLeaderboard(limit: 50);
      setState(() {
        _scores = response.leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load leaderboard';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        backgroundColor: GameColors.primary,
        foregroundColor: GameColors.textLight,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: GameColors.accent,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: GameColors.buttonDanger,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: GameColors.textLight,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.accent,
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }

    if (_scores == null || _scores!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: GameColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'No scores yet',
              style: TextStyle(
                color: GameColors.textLight,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to play!',
              style: TextStyle(
                color: GameColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scores!.length,
      itemBuilder: (context, index) {
        final score = _scores![index];
        return _LeaderboardTile(
          score: score,
          index: index,
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final ScoreModel score;
  final int index;

  const _LeaderboardTile({
    required this.score,
    required this.index,
  });

  Color _getRankColor() {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return GameColors.primary;
    }
  }

  IconData _getRankIcon() {
    switch (index) {
      case 0:
        return Icons.workspace_premium;
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index < 3 ? rankColor.withOpacity(0.1) : GameColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: index < 3 ? rankColor : GameColors.accent.withOpacity(0.3),
          width: index < 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: index < 3
                  ? Icon(
                      _getRankIcon(),
                      color: GameColors.textDark,
                      size: 28,
                    )
                  : Text(
                      '${score.rank}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GameColors.textLight,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: index < 3 ? rankColor : GameColors.textLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(score.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: GameColors.textLight.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${score.score}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GameColors.goal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}

