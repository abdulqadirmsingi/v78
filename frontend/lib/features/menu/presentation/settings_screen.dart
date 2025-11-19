import 'package:flutter/material.dart';
import 'package:street_football_rush/core/constants/colors.dart';
import 'package:street_football_rush/core/constants/api_constants.dart';
import 'package:street_football_rush/core/services/audio_service.dart';
import 'package:street_football_rush/core/services/connection_service.dart';
import 'package:street_football_rush/core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  final ConnectionService _connectionService = ConnectionService();
  
  late bool _sfxEnabled;
  late bool _musicEnabled;
  late bool _autoSubmitScore;
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  
  bool _isTestingConnection = false;
  String? _connectionTestResult;

  @override
  void initState() {
    super.initState();
    _sfxEnabled = _storage.getSfxEnabled();
    _musicEnabled = _storage.getMusicEnabled();
    _autoSubmitScore = _storage.getAutoSubmitScore();
    _nameController = TextEditingController(text: _storage.getPlayerName());
    _ipController = TextEditingController(text: _storage.getCustomIp() ?? '');
    
    // Apply initial settings
    _audio.setSfxEnabled(_sfxEnabled);
    _audio.setMusicEnabled(_musicEnabled);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    final success = await _connectionService.checkConnection();
    
    setState(() {
      _isTestingConnection = false;
      _connectionTestResult = success
          ? 'Connection successful!'
          : 'Connection failed. Check your IP address.';
    });

    // Clear message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _connectionTestResult = null;
        });
      }
    });
  }

  void _saveCustomIp(String ip) {
    _storage.saveCustomIp(ip);
    ApiConstants.setCustomMobileIp(ip.isEmpty ? null : ip);
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.background,
        title: const Text(
          'Clear All Data?',
          style: TextStyle(color: GameColors.textLight),
        ),
        content: const Text(
          'This will delete your high score and all settings. This action cannot be undone.',
          style: TextStyle(color: GameColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: GameColors.buttonDanger,
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: GameColors.buttonSuccess,
          ),
        );
        Navigator.pop(context);
      }
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Name
              _SectionHeader('PLAYER'),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: GameColors.textLight),
                maxLength: 20,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: GameColors.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: GameColors.accent),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    color: GameColors.textLight.withOpacity(0.5),
                  ),
                  counterStyle: TextStyle(
                    color: GameColors.textLight.withOpacity(0.5),
                  ),
                ),
                onChanged: (value) {
                  _storage.savePlayerName(value);
                },
              ),
              const SizedBox(height: 32),

              // Audio Settings
              _SectionHeader('AUDIO'),
              const SizedBox(height: 12),
              
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

              // Game Settings
              _SectionHeader('GAME'),
              const SizedBox(height: 12),
              
              _SettingTile(
                title: 'Auto-Submit Scores',
                subtitle: 'Automatically submit scores to leaderboard',
                icon: Icons.cloud_upload,
                value: _autoSubmitScore,
                onChanged: (value) {
                  setState(() {
                    _autoSubmitScore = value;
                  });
                  _storage.saveAutoSubmitScore(value);
                },
              ),
              const SizedBox(height: 32),

              // Connection Settings
              _SectionHeader('CONNECTION'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GameColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current API: ${ApiConstants.baseUrl}',
                      style: TextStyle(
                        color: GameColors.textLight.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ipController,
                      style: const TextStyle(color: GameColors.textLight),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: GameColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.computer, color: GameColors.accent),
                        hintText: 'Custom IP (e.g., 192.168.1.100)',
                        hintStyle: TextStyle(
                          color: GameColors.textLight.withOpacity(0.5),
                        ),
                      ),
                      onChanged: _saveCustomIp,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isTestingConnection ? null : _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.accent,
                          foregroundColor: GameColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isTestingConnection
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GameColors.textLight,
                                ),
                              )
                            : const Icon(Icons.wifi_find),
                        label: Text(
                          _isTestingConnection ? 'TESTING...' : 'TEST CONNECTION',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (_connectionTestResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _connectionTestResult!.contains('successful')
                              ? GameColors.buttonSuccess.withOpacity(0.2)
                              : GameColors.buttonDanger.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _connectionTestResult!.contains('successful')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _connectionTestResult!.contains('successful')
                                  ? GameColors.buttonSuccess
                                  : GameColors.buttonDanger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _connectionTestResult!,
                                style: TextStyle(
                                  color: _connectionTestResult!.contains('successful')
                                      ? GameColors.buttonSuccess
                                      : GameColors.buttonDanger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Danger Zone
              _SectionHeader('DANGER ZONE'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showClearDataDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.buttonDanger,
                    side: const BorderSide(color: GameColors.buttonDanger, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text(
                    'CLEAR ALL DATA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Game Info
              _SectionHeader('ABOUT'),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: GameColors.textLight,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: GameColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: GameColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: GameColors.textLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
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

