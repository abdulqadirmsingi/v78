# 🎮 Street Football Rush

A top-down arcade-style mini-football game built with Flutter/Flame frontend and Golang backend.

## 🎯 Game Concept

### Player Mechanics

- Control a single footballer using on-screen joystick
- Dribble the ball toward the goal on the opposite side
- Avoid defenders - collision means Game Over!
- Score goals to progress and increase difficulty

### Defender AI

- **Patrol Mode**: Random movement patterns
- **Chase Mode**: AI tracks and intercepts player
- **Difficulty Scaling**: Speed and count increase with each goal
- **Smart Behavior**: Prediction-based interception

### Scoring & Progression

- +1 point per goal
- Each goal increases:
  - Defender count (+1)
  - Defender speed (+10%)
  - AI reaction time (+5%)
- Local high scores + online leaderboard

### Game Screens

1. **Splash Screen** - Game logo/intro
2. **Home Menu** - Play, Settings, Leaderboard
3. **Game Screen** - Main gameplay with Flame engine
4. **Pause Screen** - Resume/Quit options
5. **Game Over** - Score display + Retry
6. **Leaderboard** - Top scores from all players

## 📁 Project Structure

```
street-football-rush/
├── backend/              # Go server with REST API
│   ├── cmd/
│   │   └── server/
│   │       └── main.go
│   ├── internal/
│   │   ├── config/
│   │   ├── leaderboard/
│   │   │   ├── entity/
│   │   │   ├── repository/
│   │   │   └── usecase/
│   │   └── server/
│   ├── pkg/
│   ├── go.mod
│   └── .env.example
├── frontend/             # Flutter + Flame game
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   └── services/
│   │   ├── features/
│   │   │   ├── game/
│   │   │   ├── leaderboard/
│   │   │   └── menu/
│   │   └── main.dart
│   ├── assets/
│   │   ├── images/
│   │   └── audio/
│   ├── test/
│   └── pubspec.yaml
└── README.md
```

## 🚀 Setup Instructions

### Prerequisites

- **Go 1.22+** - [Download](https://golang.org/dl/)
- **Flutter 3.0+** - [Install](https://flutter.dev/docs/get-started/install)
- **Git** (optional)

### Backend Setup

1. **Navigate to backend directory**:

   ```bash
   cd backend
   ```

2. **Install dependencies**:

   ```bash
   go mod download
   ```

3. **Create environment file**:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` if needed:

   ```
   PORT=8080
   ENV=development
   DB_TYPE=memory
   ```

4. **Run the server**:

   ```bash
   go run cmd/server/main.go
   ```

   Server will start on `http://localhost:8080`

5. **Test the API**:
   ```bash
   curl http://localhost:8080/health
   ```

### Frontend Setup

1. **Navigate to frontend directory**:

   ```bash
   cd frontend
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**:

   Edit `lib/core/constants/api_constants.dart`:

   ```dart
   static const String baseUrl = 'http://localhost:8080'; // Desktop
   // For mobile testing, use your computer's IP:
   // static const String baseUrl = 'http://192.168.1.X:8080';
   ```

4. **Run the app**:

   ```bash
   flutter run
   ```

   Or for web:

   ```bash
   flutter run -d chrome
   ```

### Testing

#### Backend Tests

```bash
cd backend
go test ./... -v
```

#### Frontend Tests

```bash
cd frontend
flutter test
```

## 🎮 How to Play

1. **Start Game**: Tap "Play" on home screen
2. **Movement**: Use on-screen joystick to move player
3. **Objective**: Reach the goal at the top of the field
4. **Avoid**: Don't collide with red defenders!
5. **Score**: Each goal increases difficulty
6. **Compete**: Submit your score to global leaderboard

### Controls

- **Joystick**: Move player in any direction
- **Pause Button**: Top-right corner during gameplay

## 🌐 API Documentation

### Base URL

- Development: `http://localhost:8080`
- Production: Configure your deployed URL

### Endpoints

#### 1. Health Check

```
GET /health
```

**Response**: `200 OK`

```json
{
  "status": "ok",
  "timestamp": "2025-11-19T12:00:00Z"
}
```

#### 2. Submit Score

```
POST /api/v1/score
```

**Request Body**:

```json
{
  "name": "PlayerName",
  "score": 12
}
```

**Response**: `201 Created`

```json
{
  "id": "uuid-here",
  "name": "PlayerName",
  "score": 12,
  "rank": 5,
  "created_at": "2025-11-19T12:00:00Z"
}
```

#### 3. Get Leaderboard

```
GET /api/v1/leaderboard?limit=10
```

**Query Parameters**:

- `limit` (optional): Number of entries (default: 10, max: 100)

**Response**: `200 OK`

```json
{
  "leaderboard": [
    {
      "id": "uuid",
      "name": "Player1",
      "score": 25,
      "rank": 1,
      "created_at": "2025-11-19T12:00:00Z"
    }
  ],
  "total": 1
}
```

#### 4. Get Game Configuration

```
GET /api/v1/config
```

**Response**: `200 OK`

```json
{
  "initial_defenders": 3,
  "defender_speed_base": 100.0,
  "defender_speed_increment": 10.0,
  "player_speed": 150.0,
  "field_width": 800,
  "field_height": 1200
}
```

### Error Responses

**400 Bad Request**:

```json
{
  "error": "Invalid request format"
}
```

**500 Internal Server Error**:

```json
{
  "error": "Internal server error"
}
```

## 🎨 Features

### Core Features

- ✅ Top-down 2D football gameplay
- ✅ Joystick movement controls
- ✅ AI defender with chase/patrol modes
- ✅ Collision detection
- ✅ Dynamic difficulty scaling
- ✅ Local high score tracking
- ✅ Online leaderboard

### Enhancements

- 🔊 **Sound Effects**: Goal, collision, menu clicks
- 📳 **Vibration Feedback**: On collision and goal
- ✨ **Animated Popups**: Score notifications
- ⚡ **Power-ups**: Speed boost pickups (5 seconds)
- 🎚️ **Difficulty Presets**: Easy, Medium, Hard modes
- 🎵 **Background Music**: Toggle in settings
- 📊 **Stats Tracking**: Goals, distance, time played

## 🏗️ Architecture

### Backend (Go)

- **Framework**: Fiber (high-performance HTTP)
- **Pattern**: Clean Architecture
- **Layers**:
  - Entity: Core business models
  - Repository: Data access interfaces
  - Use Case: Business logic
  - Handler: HTTP request handling
- **Storage**: In-memory (upgradable to PostgreSQL)
- **Middleware**: CORS, logging, recovery

### Frontend (Flutter/Flame)

- **Game Engine**: Flame 1.10+
- **State Management**: Riverpod
- **Architecture**: Feature-based Clean Architecture
- **Layers**:
  - Presentation: UI + Game components
  - Domain: Business logic + entities
  - Data: API clients + repositories
- **Storage**: Hive (local data)

## 🔧 Configuration

### Backend Environment Variables

```env
PORT=8080
ENV=development
DB_TYPE=memory
CORS_ORIGINS=*
LOG_LEVEL=info
```

### Frontend Configuration

Edit `lib/core/constants/game_constants.dart`:

```dart
static const double playerSpeed = 150.0;
static const int initialDefenders = 3;
static const double defenderSpeedBase = 100.0;
static const double difficultyIncrement = 0.1; // 10% per goal
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🐛 Troubleshooting

### Backend Issues

**Port already in use**:

```bash
# Change PORT in .env or kill process
lsof -ti:8080 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :8080   # Windows
```

**Module errors**:

```bash
go mod tidy
go clean -modcache
```

### Frontend Issues

**Package conflicts**:

```bash
flutter clean
flutter pub get
```

**API connection failed**:

- Verify backend is running
- Check firewall settings
- Use correct IP for mobile testing (not localhost)

**Assets not loading**:

```bash
flutter pub get
flutter clean
flutter run
```

## 🚢 Deployment

### Backend Deployment

**Docker**:

```bash
cd backend
docker build -t street-football-rush-api .
docker run -p 8080:8080 street-football-rush-api
```

**Cloud Platforms**:

- Railway / Render / Fly.io
- Upload code and configure environment variables

### Frontend Deployment

**Web**:

```bash
flutter build web
# Deploy to Firebase Hosting, Netlify, or Vercel
```

**Mobile**:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📄 License

MIT License - Feel free to use and modify

## 👨‍💻 Contributing

Pull requests welcome! Please follow the existing code structure.

## 📞 Support

Create an issue on GitHub for bugs or feature requests.

---

**Enjoy playing Street Football Rush! ⚽🔥**
