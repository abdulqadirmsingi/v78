import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/connection_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/leaderboard/data/api/leaderboard_api.dart';
import 'package:street_football_rush/features/leaderboard/data/models/score_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardApi _api = LeaderboardApi();
  final ConnectionService _connectionService = ConnectionService();
  final StorageService _storage = StorageService();
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
      final response = await _api.getLeaderboard(limit: 100);
      if (mounted) {
        setState(() {
          _scores = response.leaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  ScoreModel? _findPlayerScore() {
    if (_scores == null) return null;
    final playerName = _storage.getPlayerName();
    try {
      return _scores!.firstWhere(
        (score) => score.name.toLowerCase() == playerName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerScore = _findPlayerScore();
    
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        backgroundColor: GameColors.primary,
        foregroundColor: GameColors.textLight,
        centerTitle: true,
        actions: [
          // Connection status
          StreamBuilder<ConnectionStatus>(
            stream: _connectionService.statusStream,
            initialData: _connectionService.status,
            builder: (context, snapshot) {
              final status = snapshot.data ?? ConnectionStatus.unknown;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status == ConnectionStatus.connected
                          ? Colors.green
                          : status == ConnectionStatus.checking
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Player rank display
            if (playerScore != null && !_isLoading && _error == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GameColors.accent.withOpacity(0.2),
                      GameColors.accent.withOpacity(0.1),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: GameColors.accent.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      color: GameColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Rank: #${playerScore.rank}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GameColors.accent,
                          ),
                        ),
                        Text(
                          'Score: ${playerScore.score}',
                          style: TextStyle(
                            fontSize: 14,
                            color: GameColors.textLight.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Leaderboard list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLeaderboard,
                color: GameColors.accent,
                backgroundColor: GameColors.primary,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: GameColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading leaderboard...',
              style: TextStyle(
                color: GameColors.textLight.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GameColors.buttonDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: GameColors.buttonDanger,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connection Error',
                style: TextStyle(
                  color: GameColors.textLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: GameColors.textLight.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadLeaderboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.accent,
                  foregroundColor: GameColors.textLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_scores == null || _scores!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.leaderboard,
                size: 64,
                color: GameColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No scores yet',
              style: TextStyle(
                color: GameColors.textLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to play!',
              style: TextStyle(
                color: GameColors.textLight.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final playerName = _storage.getPlayerName();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scores!.length,
      itemBuilder: (context, index) {
        final score = _scores![index];
        final isCurrentPlayer = 
            score.name.toLowerCase() == playerName.toLowerCase();
        
        return _LeaderboardTile(
          score: score,
          index: index,
          isCurrentPlayer: isCurrentPlayer,
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final ScoreModel score;
  final int index;
  final bool isCurrentPlayer;

  const _LeaderboardTile({
    required this.score,
    required this.index,
    this.isCurrentPlayer = false,
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
        color: isCurrentPlayer
            ? GameColors.accent.withOpacity(0.15)
            : index < 3
                ? rankColor.withOpacity(0.1)
                : GameColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? GameColors.accent
              : index < 3
                  ? rankColor
                  : GameColors.accent.withOpacity(0.3),
          width: isCurrentPlayer ? 3 : (index < 3 ? 2 : 1),
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: GameColors.accent.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
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

