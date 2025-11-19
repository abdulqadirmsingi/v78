import 'package:vibration/vibration.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  bool _enabled = true;

  bool get enabled => _enabled;

  /// Check if device supports vibration
  Future<bool> hasVibrator() async {
    return await Vibration.hasVibrator() ?? false;
  }

  /// Light vibration for UI interactions
  Future<void> light() async {
    if (!_enabled) return;
    
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Silent fail on platforms without vibration
    }
  }

  /// Medium vibration for events
  Future<void> medium() async {
    if (!_enabled) return;
    
    try {
      await Vibration.vibrate(duration: 100);
    } catch (e) {
      // Silent fail
    }
  }

  /// Heavy vibration for collisions
  Future<void> heavy() async {
    if (!_enabled) return;
    
    try {
      await Vibration.vibrate(duration: 200);
    } catch (e) {
      // Silent fail
    }
  }

  /// Success pattern for goals
  Future<void> success() async {
    if (!_enabled) return;
    
    try {
      await Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, 128, 0, 255],
      );
    } catch (e) {
      // Fallback to simple vibration
      await medium();
    }
  }

  /// Toggle vibration
  void toggle() {
    _enabled = !_enabled;
  }

  /// Set enabled state
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
}

