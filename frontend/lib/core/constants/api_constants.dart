class ApiConstants {
  // Base URL - Change this to your server IP for mobile testing
  static const String baseUrl = 'http://localhost:8080';
  
  // For mobile testing, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.1.X:8080';
  
  // Endpoints
  static const String submitScoreEndpoint = '/api/v1/score';
  static const String leaderboardEndpoint = '/api/v1/leaderboard';
  static const String configEndpoint = '/api/v1/config';
  static const String healthEndpoint = '/health';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

