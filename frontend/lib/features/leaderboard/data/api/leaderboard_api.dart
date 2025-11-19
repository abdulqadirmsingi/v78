import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:street_football_rush/core/constants/api_constants.dart';
import 'package:street_football_rush/features/leaderboard/data/models/score_model.dart';

class LeaderboardApi {
  final http.Client client;

  LeaderboardApi({http.Client? client}) : client = client ?? http.Client();

  /// Submit a new score to the server
  Future<ScoreModel> submitScore(String name, int score) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.submitScoreEndpoint}',
    );

    final request = SubmitScoreRequest(name: name, score: score);

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ScoreModel.fromJson(data);
      } else {
        throw Exception('Failed to submit score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get the leaderboard with optional limit
  Future<LeaderboardResponse> getLeaderboard({int limit = 10}) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.leaderboardEndpoint}?limit=$limit',
    );

    try {
      final response = await client
          .get(url)
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LeaderboardResponse.fromJson(data);
      } else {
        throw Exception('Failed to get leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Health check to verify server connectivity
  Future<bool> healthCheck() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.healthEndpoint}',
    );

    try {
      final response = await client
          .get(url)
          .timeout(ApiConstants.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
