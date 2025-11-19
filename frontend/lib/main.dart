import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/core/services/connection_service.dart';
import 'package:street_football_rush/core/services/config_service.dart';
import 'package:street_football_rush/core/constants/api_constants.dart';
import 'package:street_football_rush/features/menu/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize services
  final storage = StorageService();
  await storage.init();

  // Load custom IP if set
  final customIp = storage.getCustomIp();
  if (customIp != null && customIp.isNotEmpty) {
    ApiConstants.setCustomMobileIp(customIp);
  }

  final audio = AudioService();
  await audio.init();

  // Load audio preferences
  final sfxEnabled = storage.getSfxEnabled();
  final musicEnabled = storage.getMusicEnabled();
  audio.setSfxEnabled(sfxEnabled);
  audio.setMusicEnabled(musicEnabled);

  // Initialize connection service
  final connectionService = ConnectionService();
  connectionService.init();

  // Pre-fetch game config (don't wait for it)
  ConfigService().getConfig().catchError((_) {
    // Silently fail and use defaults
    return GameConfigModel.defaults();
  });

  runApp(const StreetFootballRushApp());
}

class StreetFootballRushApp extends StatelessWidget {
  const StreetFootballRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Street Football Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
