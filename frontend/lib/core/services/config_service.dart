import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:street_football_rush/core/constants/api_constants.dart';
import 'package:street_football_rush/core/constants/game_constants.dart';

class GameConfigModel {
  final int initialDefenders;
  final double defenderSpeedBase;
  final double defenderSpeedIncrement;
  final double playerSpeed;
  final int fieldWidth;
  final int fieldHeight;

  GameConfigModel({
    required this.initialDefenders,
    required this.defenderSpeedBase,
    required this.defenderSpeedIncrement,
    required this.playerSpeed,
    required this.fieldWidth,
    required this.fieldHeight,
  });

  factory GameConfigModel.fromJson(Map<String, dynamic> json) {
    return GameConfigModel(
      initialDefenders: json['initial_defenders'] as int,
      defenderSpeedBase: (json['defender_speed_base'] as num).toDouble(),
      defenderSpeedIncrement:
          (json['defender_speed_increment'] as num).toDouble(),
      playerSpeed: (json['player_speed'] as num).toDouble(),
      fieldWidth: json['field_width'] as int,
      fieldHeight: json['field_height'] as int,
    );
  }

  /// Get default config from constants
  factory GameConfigModel.defaults() {
    return GameConfigModel(
      initialDefenders: GameConstants.initialDefenders,
      defenderSpeedBase: GameConstants.defenderSpeedBase,
      defenderSpeedIncrement: GameConstants.defenderSpeedIncrement,
      playerSpeed: GameConstants.playerSpeed,
      fieldWidth: GameConstants.fieldWidth.toInt(),
      fieldHeight: GameConstants.fieldHeight.toInt(),
    );
  }
}

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  final http.Client _client = http.Client();

  GameConfigModel? _cachedConfig;
  bool _isLoading = false;

  /// Get game configuration from backend or cache
  Future<GameConfigModel> getConfig({bool forceRefresh = false}) async {
    // Return cached config if available and not forcing refresh
    if (_cachedConfig != null && !forceRefresh) {
      return _cachedConfig!;
    }

    // If already loading, wait a bit and return cached or default
    if (_isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _cachedConfig ?? GameConfigModel.defaults();
    }

    _isLoading = true;

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.configEndpoint}',
      );

      final response =
          await _client.get(url).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _cachedConfig = GameConfigModel.fromJson(data);
        _isLoading = false;
        return _cachedConfig!;
      } else {
        // On error, return defaults
        _isLoading = false;
        return GameConfigModel.defaults();
      }
    } catch (e) {
      // On error, return defaults
      _isLoading = false;
      return GameConfigModel.defaults();
    }
  }

  /// Clear cached config
  void clearCache() {
    _cachedConfig = null;
  }

  /// Check if config is cached
  bool get hasCache => _cachedConfig != null;

  void dispose() {
    _client.close();
  }
}
