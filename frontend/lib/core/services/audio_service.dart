import 'package:audioplayers/audioplayers.dart';
import 'package:street_football_rush/core/constants/audio_constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Initialize audio service
  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(AudioConstants.musicVolume);
  }

  /// Play sound effect
  Future<void> playSfx(String sound) async {
    if (!_sfxEnabled) return;

    try {
      await _sfxPlayer.play(AssetSource(sound));
    } catch (e) {
      // Silent fail - assets might not exist yet
    }
  }

  /// Play background music
  Future<void> playMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource(AudioConstants.backgroundMusic));
    } catch (e) {
      // Silent fail
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Toggle sound effects
  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  /// Toggle music
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      playMusic();
    } else {
      stopMusic();
    }
  }

  /// Set SFX enabled state
  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  /// Set music enabled state
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      playMusic();
    } else {
      stopMusic();
    }
  }

  /// Dispose audio players
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}

