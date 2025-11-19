# 🚀 Complete Setup Guide - Street Football Rush

This guide will walk you through setting up and running the complete Street Football Rush game project.

---

## 📋 Prerequisites

Before starting, ensure you have the following installed:

### Required Software

1. **Go 1.22 or higher**
   - Download: https://golang.org/dl/
   - Verify: `go version`

2. **Flutter 3.0 or higher**
   - Install: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

3. **Git** (optional, for version control)
   - Download: https://git-scm.com/

### System Requirements

- **OS**: Windows 10+, macOS 10.14+, or Linux
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 2GB free space
- **Network**: Internet connection for first setup

---

## 🔧 Backend Setup (Go Server)

### Step 1: Navigate to Backend Directory

```bash
cd street-football-rush/backend
```

### Step 2: Install Go Dependencies

```bash
go mod download
```

This will download all required packages:
- Fiber (web framework)
- UUID (unique ID generation)
- godotenv (environment variables)

### Step 3: Configure Environment

The `.env` file is already created with default values:

```env
PORT=8080
ENV=development
DB_TYPE=memory
CORS_ORIGINS=*
INITIAL_DEFENDERS=3
DEFENDER_SPEED_BASE=100.0
PLAYER_SPEED=150.0
```

**Optional**: Modify these values if needed.

### Step 4: Run the Backend Server

```bash
go run cmd/server/main.go
```

You should see output like:

```
🚀 Server starting on http://localhost:8080
📊 Environment: development
🎮 Game configured with 3 initial defenders
```

### Step 5: Test the Server

Open a new terminal and test:

```bash
# Health check
curl http://localhost:8080/health

# Expected response:
# {"status":"ok","timestamp":"2025-11-19T12:00:00Z"}
```

**✅ Backend is now running!**

---

## 📱 Frontend Setup (Flutter/Flame Game)

### Step 1: Navigate to Frontend Directory

Open a **new terminal** window (keep backend running):

```bash
cd street-football-rush/frontend
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This will download:
- Flame game engine
- Riverpod (state management)
- Hive (local storage)
- HTTP client
- Audio/vibration packages

### Step 3: Generate Code

Generate JSON serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Configure API Connection

**For Desktop/Web Testing** (default):
- Already configured to use `http://localhost:8080`
- No changes needed!

**For Mobile Testing**:
1. Find your computer's local IP address:
   - **Windows**: `ipconfig` (look for IPv4 Address)
   - **macOS/Linux**: `ifconfig` or `ip addr`
   
2. Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_LOCAL_IP:8080';
   // Example: static const String baseUrl = 'http://192.168.1.100:8080';
   ```

### Step 5: Run the Flutter App

**Desktop (Windows/macOS/Linux)**:
```bash
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

**Web Browser**:
```bash
flutter run -d chrome
```

**Android Device/Emulator**:
```bash
flutter run -d android
```

**iOS Simulator** (macOS only):
```bash
flutter run -d ios
```

### Step 6: Play the Game!

The app will:
1. Show splash screen
2. Navigate to home menu
3. Display high score (0 initially)
4. Let you play!

**✅ Game is now running!**

---

## 🎮 How to Play

### Controls

1. **Move Player**: Use the on-screen joystick (bottom-left)
2. **Pause Game**: Tap pause button (top-right)

### Objective

- Navigate your player to the **golden goal area** at the top
- Avoid **red defenders** - collision = Game Over!
- Each goal increases difficulty:
  - +1 Defender
  - +10% Speed
  - Smarter AI

### Power-ups

- **Purple Star** = Speed Boost (5 seconds)
- 30% chance to spawn after scoring

### Scoring

- Each goal = +1 point
- Submit score to online leaderboard
- Beat your high score!

---

## 🧪 Testing the Full System

### Test Backend API

```bash
# 1. Health Check
curl http://localhost:8080/health

# 2. Submit a test score
curl -X POST http://localhost:8080/api/v1/score \
  -H "Content-Type: application/json" \
  -d '{"name":"TestPlayer","score":10}'

# 3. Get leaderboard
curl http://localhost:8080/api/v1/leaderboard
```

### Test Frontend

1. **Play a Game**:
   - Start app
   - Tap "PLAY"
   - Score at least 1 goal
   - Collide with defender

2. **Submit Score**:
   - On Game Over dialog
   - Tap "SUBMIT TO LEADERBOARD"
   - Check for success message

3. **View Leaderboard**:
   - Return to home
   - Tap "LEADERBOARD"
   - Verify your score appears

4. **Settings**:
   - Change player name
   - Toggle sound effects
   - Toggle music

---

## 🔥 Common Issues & Solutions

### Backend Issues

**Issue**: Port 8080 already in use

**Solution**:
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:8080 | xargs kill -9
```

**Issue**: Module errors

**Solution**:
```bash
go mod tidy
go clean -modcache
go mod download
```

### Frontend Issues

**Issue**: "Waiting for another flutter command to release the startup lock"

**Solution**:
```bash
# Delete lock file
rm <flutter-sdk>/bin/cache/lockfile

# Or just wait 1-2 minutes
```

**Issue**: Build runner errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Cannot connect to backend from mobile

**Solution**:
1. Ensure both devices on same WiFi network
2. Use computer's local IP (not localhost)
3. Check firewall - allow port 8080
4. Test backend from mobile browser: `http://YOUR_IP:8080/health`

**Issue**: Audio not playing

**Solution**:
- Audio files are optional
- App works without them (silent)
- To add audio: Place MP3 files in `assets/audio/`

---

## 📦 Building for Production

### Backend - Build Executable

```bash
cd backend

# Windows
go build -o street-football-rush-api.exe cmd/server/main.go

# macOS/Linux
go build -o street-football-rush-api cmd/server/main.go

# Run the executable
./street-football-rush-api
```

### Frontend - Build Release

**Android APK**:
```bash
cd frontend
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

**iOS App**:
```bash
flutter build ios --release
# Requires Apple Developer account
```

**Web**:
```bash
flutter build web --release

# Deploy the build/web/ folder to any web host
```

**Desktop**:
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🌐 Deployment

### Backend Deployment Options

1. **Railway**: https://railway.app/
   - Connect GitHub repo
   - Auto-deploys on push
   - Free tier available

2. **Fly.io**: https://fly.io/
   - `fly launch`
   - Global edge deployment

3. **Heroku**: https://heroku.com/
   - `git push heroku main`
   - Buildpack: Go

4. **DigitalOcean**: https://digitalocean.com/
   - Deploy on VPS
   - Use systemd for process management

### Frontend Deployment Options

1. **Web**: 
   - Vercel, Netlify, Firebase Hosting
   - Upload `build/web/` folder

2. **Mobile**:
   - Google Play Store (Android)
   - Apple App Store (iOS)

3. **Desktop**:
   - Distribute executables directly
   - Or use Windows Store / Mac App Store

---

## 📊 Project Structure Overview

```
street-football-rush/
├── backend/                    # Go REST API
│   ├── cmd/server/main.go     # Entry point
│   ├── internal/              # Business logic
│   │   ├── config/            # Configuration
│   │   ├── leaderboard/       # Leaderboard feature
│   │   └── server/            # HTTP handlers
│   ├── go.mod                 # Dependencies
│   └── .env                   # Environment config
│
├── frontend/                   # Flutter/Flame game
│   ├── lib/
│   │   ├── core/              # Constants, services
│   │   ├── features/          # Game, menu, leaderboard
│   │   └── main.dart          # Entry point
│   ├── assets/                # Images, audio
│   ├── pubspec.yaml           # Dependencies
│   └── test/                  # Tests
│
├── README.md                   # Project overview
├── API_DOCUMENTATION.md        # API reference
└── SETUP_GUIDE.md             # This file
```

---

## 🛠️ Development Workflow

### Backend Development

1. Make changes in `internal/` or `cmd/`
2. Run tests: `go test ./...`
3. Restart server: `Ctrl+C` then `go run cmd/server/main.go`

### Frontend Development

1. Make changes in `lib/`
2. Hot reload: Press `r` in terminal
3. Full restart: Press `R` in terminal
4. Run tests: `flutter test`

---

## 🎯 Next Steps

### Enhancements You Can Add

1. **More Power-ups**:
   - Shield (temporary invincibility)
   - Slow motion
   - Magnet (attract power-ups)

2. **Game Modes**:
   - Time attack
   - Endless mode
   - Story mode with levels

3. **Social Features**:
   - Friend challenges
   - Share scores
   - Achievements

4. **Cosmetics**:
   - Player skins
   - Field themes
   - Defender types

5. **Analytics**:
   - Track player behavior
   - A/B testing
   - Crash reporting

### Database Upgrade

To use PostgreSQL instead of in-memory:

1. Create `internal/leaderboard/repository/postgres_repository.go`
2. Implement `Repository` interface
3. Update `cmd/server/main.go` to use it
4. Set `DATABASE_URL` environment variable

---

## 📞 Support & Resources

### Documentation
- **Go**: https://golang.org/doc/
- **Flutter**: https://flutter.dev/docs
- **Flame**: https://docs.flame-engine.org/

### Community
- Go Forum: https://forum.golangbridge.org/
- Flutter Discord: https://flutter.dev/community
- Stack Overflow: Tag with `go`, `flutter`, `flame-engine`

### Troubleshooting
1. Check backend logs in terminal
2. Check Flutter logs with `flutter logs`
3. Verify network connectivity
4. Test API with curl/Postman
5. Clear cache: `flutter clean` / `go clean`

---

## ✅ Checklist

Use this to verify your setup:

- [ ] Go installed and verified
- [ ] Flutter installed and verified
- [ ] Backend dependencies downloaded
- [ ] Backend server running on port 8080
- [ ] Backend health check successful
- [ ] Frontend dependencies downloaded
- [ ] Code generation completed
- [ ] Frontend app running
- [ ] Able to play game
- [ ] Score submission works
- [ ] Leaderboard displays correctly
- [ ] Settings save properly

---

## 🎉 You're All Set!

Congratulations! You now have a fully functional game with:

✅ Go backend with REST API
✅ Flutter/Flame game engine
✅ Online leaderboard
✅ Local storage
✅ Sound effects & vibration
✅ Multiple screens & dialogs
✅ Difficulty scaling
✅ Power-ups
✅ AI defenders

**Enjoy playing Street Football Rush! ⚽🔥**

---

## 📝 License

This project is open source under the MIT License.
Feel free to use, modify, and distribute as needed.

---

**Last Updated**: November 19, 2025
**Version**: 1.0.0

