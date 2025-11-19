import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'street_football_rush';
  static const String _highScoreKey = 'high_score';
  static const String _playerNameKey = 'player_name';
  static const String _sfxEnabledKey = 'sfx_enabled';
  static const String _musicEnabledKey = 'music_enabled';

  late Box _box;

  /// Initialize Hive storage
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Get high score
  int getHighScore() {
    return _box.get(_highScoreKey, defaultValue: 0) as int;
  }

  /// Save high score
  Future<void> saveHighScore(int score) async {
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      await _box.put(_highScoreKey, score);
    }
  }

  /// Get player name
  String getPlayerName() {
    return _box.get(_playerNameKey, defaultValue: 'Player') as String;
  }

  /// Save player name
  Future<void> savePlayerName(String name) async {
    await _box.put(_playerNameKey, name);
  }

  /// Get SFX enabled state
  bool getSfxEnabled() {
    return _box.get(_sfxEnabledKey, defaultValue: true) as bool;
  }

  /// Save SFX enabled state
  Future<void> saveSfxEnabled(bool enabled) async {
    await _box.put(_sfxEnabledKey, enabled);
  }

  /// Get music enabled state
  bool getMusicEnabled() {
    return _box.get(_musicEnabledKey, defaultValue: true) as bool;
  }

  /// Save music enabled state
  Future<void> saveMusicEnabled(bool enabled) async {
    await _box.put(_musicEnabledKey, enabled);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _box.clear();
  }
}

