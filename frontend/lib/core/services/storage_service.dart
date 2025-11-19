import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'street_football_rush';
  static const String _highScoreKey = 'high_score';
  static const String _playerNameKey = 'player_name';
  static const String _sfxEnabledKey = 'sfx_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _customIpKey = 'custom_ip';
  static const String _autoSubmitScoreKey = 'auto_submit_score';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box? _box;
  bool _isInitialized = false;

  /// Initialize Hive storage
  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  /// Ensure storage is initialized (for safety)
  void _ensureInitialized() {
    if (!_isInitialized || _box == null) {
      throw StateError(
        'StorageService not initialized. Call init() first.',
      );
    }
  }

  /// Get high score
  int getHighScore() {
    _ensureInitialized();
    return _box!.get(_highScoreKey, defaultValue: 0) as int;
  }

  /// Save high score
  Future<void> saveHighScore(int score) async {
    _ensureInitialized();
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      await _box!.put(_highScoreKey, score);
    }
  }

  /// Get player name
  String getPlayerName() {
    _ensureInitialized();
    return _box!.get(_playerNameKey, defaultValue: 'Player') as String;
  }

  /// Save player name
  Future<void> savePlayerName(String name) async {
    _ensureInitialized();
    await _box!.put(_playerNameKey, name);
  }

  /// Get SFX enabled state
  bool getSfxEnabled() {
    _ensureInitialized();
    return _box!.get(_sfxEnabledKey, defaultValue: true) as bool;
  }

  /// Save SFX enabled state
  Future<void> saveSfxEnabled(bool enabled) async {
    _ensureInitialized();
    await _box!.put(_sfxEnabledKey, enabled);
  }

  /// Get music enabled state
  bool getMusicEnabled() {
    _ensureInitialized();
    return _box!.get(_musicEnabledKey, defaultValue: true) as bool;
  }

  /// Save music enabled state
  Future<void> saveMusicEnabled(bool enabled) async {
    _ensureInitialized();
    await _box!.put(_musicEnabledKey, enabled);
  }

  /// Get custom IP address
  String? getCustomIp() {
    _ensureInitialized();
    return _box!.get(_customIpKey) as String?;
  }

  /// Save custom IP address
  Future<void> saveCustomIp(String? ip) async {
    _ensureInitialized();
    if (ip == null || ip.isEmpty) {
      await _box!.delete(_customIpKey);
    } else {
      await _box!.put(_customIpKey, ip);
    }
  }

  /// Get auto-submit score setting
  bool getAutoSubmitScore() {
    _ensureInitialized();
    return _box!.get(_autoSubmitScoreKey, defaultValue: false) as bool;
  }

  /// Save auto-submit score setting
  Future<void> saveAutoSubmitScore(bool enabled) async {
    _ensureInitialized();
    await _box!.put(_autoSubmitScoreKey, enabled);
  }

  /// Clear all data
  Future<void> clearAll() async {
    _ensureInitialized();
    await _box!.clear();
  }
}

