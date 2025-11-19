# ⚡ Quick Start - Street Football Rush

Get the game running in under 5 minutes!

---

## 🎯 Goal

Have both backend and frontend running and play the game.

---

## 📋 Prerequisites Check

Before starting, verify you have these installed:

```bash
# Check Go
go version
# Expected: go version go1.22.x or higher

# Check Flutter
flutter --version
# Expected: Flutter 3.x.x or higher
```

❌ **Don't have them?**

- Install Go: https://golang.org/dl/
- Install Flutter: https://flutter.dev/docs/get-started/install

---

## 🚀 5-Minute Setup

### Terminal 1: Backend

```bash
# 1. Go to backend directory
cd street-football-rush/backend

# 2. Install dependencies (first time only)
go mod download

# 3. Run the server
go run cmd/server/main.go
```

**Expected output**:

```
🚀 Server starting on http://localhost:8080
📊 Environment: development
🎮 Game configured with 3 initial defenders
```

✅ **Leave this terminal running!**

---

### Terminal 2: Frontend

**Open a NEW terminal window** (don't close the first one!)

```bash
# 1. Go to frontend directory
cd street-football-rush/frontend

# 2. Install dependencies (first time only)
flutter pub get

# 3. Generate code (first time only)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

**Choose your platform**:

- Desktop: Select Windows/macOS/Linux option
- Web: Select Chrome option
- Mobile: Connect device or start emulator first

✅ **App will launch!**

---

## 🎮 Playing the Game

1. **Splash Screen** appears (3 seconds)
2. **Home Menu** shows up
3. **Tap "PLAY"** button
4. **Use joystick** (bottom-left) to move blue player
5. **Reach golden goal** at top to score
6. **Avoid red defenders** or it's game over!
7. **Pause button** at top-right if needed

---

## ✅ Quick Test

### Test Backend is Running

Open a third terminal:

```bash
curl http://localhost:8080/health
```

**Expected**: `{"status":"ok","timestamp":"..."}`

### Test Frontend Connection

In the game:

1. Play and score a goal
2. Collide with a defender (game over)
3. Tap "SUBMIT TO LEADERBOARD"
4. Go back and tap "LEADERBOARD"
5. Your score should appear!

---

## 🐛 Quick Troubleshooting

### Backend Issues

**"Port 8080 already in use"**:

```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:8080 | xargs kill -9
```

**"Module not found"**:

```bash
go mod tidy
go mod download
```

### Frontend Issues

**"Waiting for another flutter command"**:

- Wait 1-2 minutes OR
- Delete `<flutter-sdk>/bin/cache/lockfile`

**"Cannot connect to backend" (mobile)**:

- Edit `lib/core/constants/api_constants.dart`
- Change `localhost` to your computer's IP
- Example: `http://192.168.1.100:8080`

**"Assets not found"**:

- This is OK! Audio/images are optional
- Game works without them (no sound)

---

## 🎯 What's Next?

### Try These Features

✅ **Change Settings**:

- Home → Settings
- Change your name
- Toggle sound effects/music

✅ **View Leaderboard**:

- Home → Leaderboard
- See all player scores
- Top 3 get special badges

✅ **Challenge Yourself**:

- Try to beat your high score
- Reach 10+ goals
- See how fast defenders get!

### Customize the Game

**Make it easier/harder**:

Edit `backend/.env`:

```env
INITIAL_DEFENDERS=2           # Start with fewer defenders
DEFENDER_SPEED_BASE=80.0      # Slower defenders
PLAYER_SPEED=200.0            # Faster player
```

Restart backend to apply changes!

---

## 📚 Learn More

Now that it's running, explore:

- `README.md` - Project overview
- `SETUP_GUIDE.md` - Detailed setup
- `API_DOCUMENTATION.md` - Backend API
- `GAME_DESIGN.md` - How the game works
- `PROJECT_SUMMARY.md` - Complete feature list

---

## 🎉 You're Ready!

**Both backend and frontend are running!**

Enjoy playing Street Football Rush! ⚽🔥

---

## 💡 Pro Tips

1. **Keep backend running** while playing
2. **Use Chrome for web** - best performance
3. **Check console logs** if something breaks
4. **Restart both** if connection fails
5. **Read GAME_DESIGN.md** to understand AI behavior

---

## 🆘 Still Stuck?

1. Make sure both terminals are still running
2. Check for error messages in terminals
3. Verify prerequisites are installed correctly
4. Read SETUP_GUIDE.md for detailed help
5. Try the test commands above

---

**Happy Gaming! 🎮**
