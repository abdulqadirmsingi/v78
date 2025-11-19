import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Environment configuration
  static const String _productionUrl = 'https://your-production-url.com';
  static const String _developmentUrl = 'http://localhost:8080';
  
  // Configurable IP for mobile testing
  static String? customMobileIp;
  
  /// Get the appropriate base URL based on platform and environment
  static String get baseUrl {
    // Check for custom mobile IP first
    if (customMobileIp != null && customMobileIp!.isNotEmpty) {
      return 'http://$customMobileIp:8080';
    }
    
    // Platform-specific defaults
    if (kIsWeb) {
      // For web, try to use relative URLs or localhost
      return _developmentUrl;
    } else {
      // For mobile and desktop
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          // For Android emulator, 10.0.2.2 maps to host machine's localhost
          // For iOS simulator, localhost works
          // For real devices, user should set customMobileIp
          return Platform.isAndroid 
              ? 'http://10.0.2.2:8080' 
              : _developmentUrl;
        } else {
          // Desktop platforms (Windows, macOS, Linux)
          return _developmentUrl;
        }
      } catch (e) {
        // Fallback if Platform is not available
        return _developmentUrl;
      }
    }
  }
  
  /// Set custom IP for mobile testing
  static void setCustomMobileIp(String? ip) {
    customMobileIp = ip;
  }
  
  /// Check if using production environment
  static bool get isProduction => baseUrl == _productionUrl;
  
  // Endpoints
  static const String submitScoreEndpoint = '/api/v1/score';
  static const String leaderboardEndpoint = '/api/v1/leaderboard';
  static const String configEndpoint = '/api/v1/config';
  static const String healthEndpoint = '/health';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;
}

