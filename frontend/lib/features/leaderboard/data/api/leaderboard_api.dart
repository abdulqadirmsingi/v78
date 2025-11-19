import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:street_football_rush/core/constants/api_constants.dart';
import 'package:street_football_rush/features/leaderboard/data/models/score_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

class LeaderboardApi {
  final http.Client client;

  LeaderboardApi({http.Client? client}) : client = client ?? http.Client();

  /// Retry a request with exponential backoff
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = ApiConstants.maxRetries,
  }) async {
    int retryCount = 0;
    
    while (true) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          rethrow;
        }
        
        // Exponential backoff
        await Future.delayed(
          ApiConstants.retryDelay * retryCount,
        );
      }
    }
  }

  /// Handle HTTP errors and convert to user-friendly messages
  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Cannot connect to server. Please check your internet connection.';
    } else if (error is TimeoutException) {
      return 'Connection timeout. Please try again.';
    } else if (error is ApiException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Submit a new score to the server
  Future<ScoreModel> submitScore(String name, int score) async {
    return _retryRequest(() async {
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
        } else if (response.statusCode == 400) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          throw ApiException(
            data['error'] ?? 'Invalid request',
            response.statusCode,
          );
        } else {
          throw ApiException(
            'Failed to submit score',
            response.statusCode,
          );
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(_getErrorMessage(e));
      }
    });
  }

  /// Get the leaderboard with optional limit
  Future<LeaderboardResponse> getLeaderboard({int limit = 10}) async {
    return _retryRequest(() async {
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
          throw ApiException(
            'Failed to load leaderboard',
            response.statusCode,
          );
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(_getErrorMessage(e));
      }
    });
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
