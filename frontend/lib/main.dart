import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';
import 'package:street_football_rush/features/menu/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final storage = StorageService();
  await storage.init();

  final audio = AudioService();
  await audio.init();

  // Load audio preferences
  final sfxEnabled = storage.getSfxEnabled();
  final musicEnabled = storage.getMusicEnabled();
  audio.setSfxEnabled(sfxEnabled);
  audio.setMusicEnabled(musicEnabled);

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

