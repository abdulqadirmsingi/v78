# Street Football Rush - Frontend

Flutter mobile game with Flame engine for Street Football Rush.

## Features

- **Flame Game Engine** for smooth 2D gameplay
- **Riverpod** state management
- **Hive** local storage for high scores
- **HTTP** API integration with backend
- **Audio** effects and background music
- **Vibration** feedback
- Clean architecture with feature-based organization

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+

### Installation

1. **Install dependencies**:

```bash
flutter pub get
```

2. **Generate code** (for JSON serialization):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Configure API endpoint**:

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:8080';
```

For desktop/web testing, use `http://localhost:8080`

For mobile testing, use your computer's local IP (e.g., `http://192.168.1.100:8080`)

### Running the App

**Desktop/Web**:

```bash
flutter run
```

**Android**:

```bash
flutter run -d android
```

**iOS**:

```bash
flutter run -d ios
```

**Web**:

```bash
flutter run -d chrome
```

### Building

**Android APK**:

```bash
flutter build apk --release
```

**iOS**:

```bash
flutter build ios --release
```

**Web**:

```bash
flutter build web --release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/        # Game constants, colors, API config
│   └── services/         # Audio, storage, vibration services
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   └── entities/  # Player, Defender, Goal, PowerUp
│   │   └── presentation/  # Game screen, dialogs
│   ├── leaderboard/
│   │   ├── data/
│   │   │   ├── api/       # HTTP client
│   │   │   └── models/    # JSON models
│   │   └── presentation/  # Leaderboard screen
│   └── menu/
│       └── presentation/  # Home, Settings, Splash screens
└── main.dart
```

## Game Controls

- **Joystick**: Move player with on-screen joystick (bottom-left)
- **Pause**: Tap pause button (top-right)

## Troubleshooting

### Assets not found

Make sure to create placeholder assets or the app will silently fail to load them:

```bash
mkdir -p assets/images assets/audio
# Add placeholder files (optional - app works without them)
```

### API connection failed

1. Verify backend is running
2. Check API endpoint in `api_constants.dart`
3. For mobile, use local network IP, not localhost
4. Check firewall settings

### Build runner errors

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

Run tests:

```bash
flutter test
```

## License

MIT
