import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  
  late bool _sfxEnabled;
  late bool _musicEnabled;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _sfxEnabled = _storage.getSfxEnabled();
    _musicEnabled = _storage.getMusicEnabled();
    _nameController = TextEditingController(text: _storage.getPlayerName());
    
    // Apply initial settings
    _audio.setSfxEnabled(_sfxEnabled);
    _audio.setMusicEnabled(_musicEnabled);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: GameColors.primary,
        foregroundColor: GameColors.textLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Name
              const Text(
                'PLAYER NAME',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: GameColors.textLight),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: GameColors.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    color: GameColors.textLight.withOpacity(0.5),
                  ),
                ),
                onChanged: (value) {
                  _storage.savePlayerName(value);
                },
              ),
              const SizedBox(height: 32),

              // Audio Settings
              const Text(
                'AUDIO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              
              // Sound Effects Toggle
              _SettingTile(
                title: 'Sound Effects',
                icon: Icons.volume_up,
                value: _sfxEnabled,
                onChanged: (value) {
                  setState(() {
                    _sfxEnabled = value;
                  });
                  _audio.setSfxEnabled(value);
                  _storage.saveSfxEnabled(value);
                },
              ),
              const SizedBox(height: 12),

              // Music Toggle
              _SettingTile(
                title: 'Background Music',
                icon: Icons.music_note,
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() {
                    _musicEnabled = value;
                  });
                  _audio.setMusicEnabled(value);
                  _storage.saveMusicEnabled(value);
                },
              ),
              const SizedBox(height: 32),

              // Game Info
              const Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GameColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Street Football Rush',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GameColors.accent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: GameColors.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Navigate your player to the goal while avoiding defenders. Each goal increases the difficulty!',
                      style: TextStyle(
                        color: GameColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: GameColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: GameColors.textLight,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: GameColors.accent,
          ),
        ],
      ),
    );
  }
}

