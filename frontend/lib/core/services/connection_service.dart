import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:street_football_rush/core/constants/api_constants.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  checking,
  unknown,
}

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final http.Client _client = http.Client();

  ConnectionStatus _status = ConnectionStatus.unknown;
  ConnectionStatus get status => _status;

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  Timer? _periodicCheck;
  bool _isChecking = false;

  /// Initialize the connection service and start periodic checks
  void init({Duration checkInterval = const Duration(seconds: 30)}) {
    // Do initial check
    checkConnection();

    // Start periodic checks
    _periodicCheck?.cancel();
    _periodicCheck = Timer.periodic(checkInterval, (_) {
      checkConnection();
    });
  }

  /// Check backend health
  Future<bool> checkConnection() async {
    if (_isChecking) return _status == ConnectionStatus.connected;

    _isChecking = true;
    _updateStatus(ConnectionStatus.checking);

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.healthEndpoint}',
      );

      final response =
          await _client.get(url).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        _updateStatus(ConnectionStatus.connected);
        _isChecking = false;
        return true;
      } else {
        _updateStatus(ConnectionStatus.disconnected);
        _isChecking = false;
        return false;
      }
    } catch (e) {
      _updateStatus(ConnectionStatus.disconnected);
      _isChecking = false;
      return false;
    }
  }

  /// Get connection status with a single check
  Future<ConnectionStatus> getStatus() async {
    await checkConnection();
    return _status;
  }

  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }

  /// Stop periodic checks
  void dispose() {
    _periodicCheck?.cancel();
    _statusController.close();
    _client.close();
  }

  /// Get connection status as a user-friendly string
  String get statusText {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.checking:
        return 'Connecting...';
      case ConnectionStatus.unknown:
        return 'Unknown';
    }
  }

  /// Check if currently connected
  bool get isConnected => _status == ConnectionStatus.connected;
}
