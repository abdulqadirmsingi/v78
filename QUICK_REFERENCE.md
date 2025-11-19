# 📋 Quick Reference Card - Street Football Rush

One-page cheat sheet for developers.

---

## 🚀 Commands

### Backend

```bash
# Development
cd backend
go run cmd/server/main.go

# Test
go test ./... -v

# Build
go build -o api cmd/server/main.go

# Docker
docker build -t street-football-api .
docker run -p 8080:8080 street-football-api
```

### Frontend

```bash
# Development
cd frontend
flutter run

# Test
flutter test

# Build
flutter build apk --release        # Android
flutter build web --release        # Web
flutter build windows --release    # Windows
```

---

## 🌐 API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Health check |
| POST | `/api/v1/score` | Submit score |
| GET | `/api/v1/leaderboard?limit=10` | Get leaderboard |
| GET | `/api/v1/config` | Game config |

**Example**:
```bash
curl -X POST http://localhost:8080/api/v1/score \
  -H "Content-Type: application/json" \
  -d '{"name":"Player","score":10}'
```

---

## 🎮 Game Mechanics

### Controls
- **Joystick**: Move player (bottom-left)
- **Pause**: Top-right button

### Entities
| Entity | Color | Speed | Role |
|--------|-------|-------|------|
| Player | Blue | 150 px/s | User-controlled |
| Defender | Red | 100+ px/s | AI enemy |
| Goal | Gold | - | Score zone |
| Power-up | Purple | - | Speed boost |

### Difficulty Progression
- **Defenders**: 3 → 10 (+1 per goal)
- **Speed**: ×1.1 per goal (exponential)
- **AI**: Gets smarter over time

---

## 📂 Project Structure

```
backend/
├── cmd/server/main.go         # Entry
├── internal/
│   ├── config/                # Config
│   ├── leaderboard/           # Feature
│   └── server/                # HTTP
└── .env                       # Settings

frontend/
├── lib/
│   ├── core/                  # Shared
│   ├── features/              # Features
│   └── main.dart              # Entry
└── assets/                    # Media
```

---

## 🔧 Configuration

### Backend (.env)

```env
PORT=8080
INITIAL_DEFENDERS=3
DEFENDER_SPEED_BASE=100.0
PLAYER_SPEED=150.0
CORS_ORIGINS=*
```

### Frontend (api_constants.dart)

```dart
static const String baseUrl = 'http://localhost:8080';
```

---

## 🐛 Quick Fixes

### Port in use
```bash
# Kill process on port 8080
lsof -ti:8080 | xargs kill -9  # Mac/Linux
netstat -ano | findstr :8080   # Windows
```

### Flutter lock
```bash
flutter clean
flutter pub get
```

### Backend deps
```bash
go mod tidy
go mod download
```

### Cannot connect (mobile)
Change `localhost` to computer's IP in `api_constants.dart`

---

## 📊 Key Files

| File | Purpose |
|------|---------|
| `backend/cmd/server/main.go` | Backend entry |
| `frontend/lib/main.dart` | Frontend entry |
| `backend/.env` | Backend config |
| `frontend/lib/core/constants/` | Frontend config |
| `backend/internal/leaderboard/` | Leaderboard logic |
| `frontend/lib/features/game/` | Game logic |

---

## 🧪 Testing

### Backend
```bash
cd backend
go test ./internal/leaderboard/usecase -v
```

### Frontend
```bash
cd frontend
flutter test
```

### API
```bash
curl http://localhost:8080/health
```

---

## 📦 Dependencies

### Backend
- Fiber: Web framework
- UUID: ID generation
- godotenv: Env vars

### Frontend
- Flame: Game engine
- Riverpod: State management
- Hive: Local storage
- HTTP: API client

---

## 🎯 Game Constants

```dart
// Speed
playerSpeed: 150.0
defenderSpeedBase: 100.0
speedBoostMultiplier: 1.5

// Difficulty
initialDefenders: 3
maxDefenders: 10
difficultyMultiplier: 1.1

// Power-ups
powerUpDuration: 5.0 seconds
spawnChance: 30%
```

---

## 🔑 Key Concepts

### Backend Architecture
- **Entity**: Domain models
- **Repository**: Data access
- **Use Case**: Business logic
- **Handler**: HTTP layer

### Frontend Architecture
- **Entity**: Game objects
- **Service**: Shared services
- **Screen**: UI pages
- **Dialog**: Overlays

---

## 📞 URLs

- **Backend**: `http://localhost:8080`
- **Health**: `http://localhost:8080/health`
- **API Docs**: `API_DOCUMENTATION.md`
- **Setup**: `SETUP_GUIDE.md`

---

## 🎨 Colors

```dart
fieldGreen: #2E8B57
player: #0066FF
defender: #FF3333
goal: #FFD700
powerUp: #FF00FF
```

---

## 🚨 Common Errors

| Error | Fix |
|-------|-----|
| Port 8080 in use | Kill process |
| Cannot find module | `go mod download` |
| Flutter waiting | Wait or delete lockfile |
| Assets not found | Optional - app works without |
| Cannot connect | Check backend running, verify IP |

---

## 📈 Performance Targets

- **FPS**: 60
- **Response**: <50ms
- **Memory**: <100MB
- **Load**: <2s

---

## 🎮 Pro Tips

1. Keep backend running while playing
2. Use Chrome for web (best performance)
3. Check logs for errors
4. Test API with curl first
5. Read GAME_DESIGN.md for mechanics

---

## 📚 Documentation

- `README.md` - Overview
- `QUICKSTART.md` - 5-min setup
- `SETUP_GUIDE.md` - Detailed setup
- `API_DOCUMENTATION.md` - API reference
- `GAME_DESIGN.md` - Game mechanics
- `PROJECT_SUMMARY.md` - Complete list
- `QUICK_REFERENCE.md` - This file

---

## ✅ Checklist

- [ ] Go & Flutter installed
- [ ] Backend running (port 8080)
- [ ] Frontend running
- [ ] Health check passes
- [ ] Game playable
- [ ] Score submission works
- [ ] Leaderboard shows scores

---

**Keep this card handy while developing! 📋**

