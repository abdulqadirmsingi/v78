# 🎮 Game Design Document - Street Football Rush

Complete game mechanics, rules, and design specifications.

---

## 🎯 Game Overview

**Title**: Street Football Rush

**Genre**: Top-down arcade sports game

**Platform**: Mobile (iOS/Android), Desktop (Windows/macOS/Linux), Web

**Target Audience**: Casual gamers, ages 8+

**Play Time**: 1-5 minutes per session

**Objective**: Score goals while avoiding defenders, achieve the highest score possible

---

## 🎲 Core Gameplay Mechanics

### Player Control

**Movement System**:

- On-screen joystick (bottom-left corner)
- 360-degree directional movement
- Smooth, responsive controls
- Speed: 150 pixels/second (base)

**Player Properties**:

- Size: 20px radius circular hitbox
- Color: Blue (#0066FF)
- Visual indicator: Small dot showing forward direction
- Collision: Loses when touching defenders

### Goal Mechanics

**Goal Zone**:

- Location: Top of the field
- Size: 200px wide × 60px tall
- Color: Golden (#FFD700)
- Detection: Continuous collision check
- Visual: Net pattern, glowing border

**Scoring**:

- +1 point per goal
- Instant score update in UI
- Visual feedback: "Goal!" popup animation
- Audio feedback: Goal sound effect
- Haptic feedback: Success vibration pattern
- Player respawns at starting position after goal

### Defender AI

**Behavior States**:

1. **Patrol Mode** (Default):

   - Random movement within field
   - Speed: 70% of base defender speed
   - Change target every 2-5 seconds
   - Avoids field boundaries

2. **Chase Mode** (Active):
   - Triggered when player within 300px
   - Speed: 100% of base defender speed
   - Uses prediction algorithm to intercept
   - Color changes to brighter red
   - Visual indicator: Exclamation mark above head

**AI Intelligence**:

- Simple prediction: Aims ahead of player's position
- Hysteresis: Won't rapidly switch between patrol/chase
- Boundary awareness: Stays within playable area
- Collision avoidance: Won't overlap with each other

**Defender Properties**:

- Size: 20px radius
- Color: Red (#FF3333) / Bright Red (#FF6666) when chasing
- Initial count: 3 defenders
- Max count: 10 defenders

### Difficulty Scaling

**Progressive Difficulty** (per goal scored):

1. **Defender Count**:

   - Starts: 3 defenders
   - Increase: +1 per goal
   - Maximum: 10 defenders
   - Spawn location: Random (upper half of field)

2. **Defender Speed**:

   - Base: 100 pixels/second
   - Increase: ×1.1 per goal (10% faster)
   - Formula: `base_speed × (1.1 ^ goals_scored)`
   - No maximum (exponential difficulty)

3. **AI Reaction**:
   - Chase distance scales slightly with score
   - Prediction accuracy increases
   - Patrol randomness decreases

**Example Progression**:

```
Goals | Defenders | Speed  | Difficulty
------|-----------|--------|------------
0     | 3         | 100    | Easy
5     | 8         | 161    | Medium
10    | 10        | 259    | Hard
15    | 10        | 418    | Very Hard
20    | 10        | 673    | Extreme
```

### Power-ups

**Speed Boost**:

- Visual: Purple star with pulsing animation
- Effect: 1.5× player speed for 5 seconds
- Spawn chance: 30% after scoring goal
- Duration: Remains until collected or new goal
- Indicator: Purple glow around player when active
- Stacking: No (resets timer if collected again)

**Future Power-ups** (not implemented):

- Shield: Temporary invincibility
- Slow Motion: Slows defenders
- Teleport: Instant position change

---

## 🎨 Visual Design

### Color Palette

| Element          | Color      | Hex Code | Purpose         |
| ---------------- | ---------- | -------- | --------------- |
| Field            | Green      | #2E8B57  | Background      |
| Lines            | White      | #FFFFFF  | Field markings  |
| Player           | Blue       | #0066FF  | Main character  |
| Defender         | Red        | #FF3333  | Enemies         |
| Defender (Chase) | Bright Red | #FF6666  | Active enemies  |
| Goal             | Gold       | #FFD700  | Target zone     |
| Power-up         | Magenta    | #FF00FF  | Collectible     |
| UI Background    | Dark Blue  | #1A1A2E  | Menu background |
| UI Primary       | Navy       | #0F3460  | Buttons         |
| UI Accent        | Pink       | #E94560  | Highlights      |

### Field Layout

```
┌────────────────────────┐
│      [GOAL ZONE]       │  ← Top (y=50-110)
├────────────────────────┤
│                        │
│    Defender Area       │  ← Upper half
│   (Spawn + Patrol)     │
│                        │
├────────────────────────┤
│                        │
│    Player Area         │  ← Lower half
│   (Starting zone)      │
│                        │
│         👤             │  ← Player start (bottom center)
│                        │
└────────────────────────┘
      [JOYSTICK]          ← Bottom-left UI
```

### UI Elements

**Game Screen**:

- Top bar: Score display with icon
- Pause button: Top-right corner
- Joystick: Bottom-left overlay
- Power-up indicator: Around player when active

**Home Screen**:

- Large title: "STREET FOOTBALL RUSH"
- High score display
- Play button (green)
- Leaderboard button (blue)
- Settings button (blue)

**Dialogs**:

- Semi-transparent dark overlay
- Rounded corners
- Colored borders
- Large icons
- Clear button hierarchy

---

## 🔊 Audio Design

### Sound Effects

| Event        | Sound Type    | Volume | Priority |
| ------------ | ------------- | ------ | -------- |
| Goal         | Cheer/whistle | 70%    | High     |
| Collision    | Crash/thud    | 70%    | High     |
| Power-up     | Magical chime | 70%    | Medium   |
| Button click | Click/tap     | 70%    | Low      |

**Implementation**:

- Format: MP3 (cross-platform)
- Length: <2 seconds
- Looping: None (except music)
- Fallback: Silent if files missing

### Background Music

- Type: Upbeat, energetic
- Tempo: 120-140 BPM
- Volume: 30%
- Looping: Yes
- Toggleable: Via settings

---

## 📳 Haptic Feedback

| Event     | Pattern      | Duration  |
| --------- | ------------ | --------- |
| Goal      | Double pulse | 100ms × 2 |
| Collision | Heavy        | 200ms     |
| Power-up  | Light        | 50ms      |
| Button    | Light        | 50ms      |

**Platforms**:

- Android: Vibration API
- iOS: Haptic Engine
- Desktop: Not supported

---

## 🎮 Game States

### State Machine

```
Splash Screen (3s)
    ↓
Home Menu
    ↓
┌───┴────┬─────────┐
│        │         │
Playing  Settings  Leaderboard
│        │         │
↓        └─────────┘
Paused
│
↓
Game Over
│
└─→ Home Menu (loop)
```

### Screen Details

**1. Splash Screen**:

- Duration: 3 seconds
- Animation: Fade in + scale
- Branding: Logo + title
- Auto-navigate: → Home Menu

**2. Home Menu**:

- Display: High score
- Buttons: Play, Leaderboard, Settings
- Background: Animated gradient
- Music: Starts playing

**3. Game Screen**:

- HUD: Score at top
- Controls: Joystick + Pause button
- Game area: Field with entities
- Updates: 60 FPS

**4. Pause Dialog**:

- Overlay: Semi-transparent
- Options: Resume, Restart, Home
- State: Game engine paused

**5. Game Over Dialog**:

- Display: Final score
- Highlight: New high score (if achieved)
- Actions: Submit score, Restart, Home
- Auto-save: High score locally

**6. Leaderboard Screen**:

- Display: Top 50 scores
- Sorting: By score (descending)
- Info: Rank, Name, Score, Time
- Actions: Refresh, Back
- Visual: Gold/Silver/Bronze for top 3

**7. Settings Screen**:

- Input: Player name
- Toggles: Sound effects, Music
- Info: Game version, Description
- Persistent: Saves to local storage

---

## 💾 Data Management

### Local Storage (Hive)

**Stored Data**:

- High score (integer)
- Player name (string)
- SFX enabled (boolean)
- Music enabled (boolean)

**Persistence**:

- Saves immediately on change
- Survives app restart
- Platform-specific location

### Online Storage (Backend)

**Leaderboard Entries**:

```json
{
  "id": "uuid",
  "name": "Player",
  "score": 25,
  "rank": 1,
  "created_at": "2025-11-19T12:00:00Z"
}
```

**Sync Logic**:

- Submit: Manual (button on game over)
- Retrieve: Automatic on leaderboard screen
- Caching: None (always fresh data)
- Offline: Graceful failure (shows error)

---

## ⚙️ Technical Specifications

### Performance Targets

- **Frame Rate**: 60 FPS
- **Input Latency**: <50ms
- **Load Time**: <2 seconds
- **Memory**: <100MB RAM
- **Battery**: Optimized (no excessive polling)

### Game Loop

```
┌─────────────────┐
│  Update (dt)    │  ← 60 times/second
├─────────────────┤
│ • Player input  │
│ • Defender AI   │
│ • Collisions    │
│ • Power-ups     │
│ • Game state    │
├─────────────────┤
│  Render         │
├─────────────────┤
│ • Field         │
│ • Entities      │
│ • Effects       │
│ • UI overlay    │
└─────────────────┘
```

### Physics

**Collision Detection**:

- Type: Circle-circle (player-defender)
- Type: Circle-rectangle (player-goal)
- Algorithm: Distance check (efficient)
- Precision: Pixel-perfect

**Movement**:

- Type: Velocity-based
- Friction: None (instant stop)
- Bounds: Clamped to field
- Smoothing: Linear interpolation

---

## 🏆 Achievements (Future)

Potential achievements to implement:

- 🥇 **First Goal**: Score your first goal
- 🔥 **Hot Streak**: Score 5 goals in one game
- 🏃 **Speed Demon**: Collect 10 speed boosts
- 💯 **Century**: Reach 100 total goals
- 👑 **Leaderboard King**: Reach #1 rank
- 🛡️ **Survivor**: Play for 3 minutes without collision
- 🎯 **Marksman**: Score 20 goals in one game

---

## 📊 Analytics Events (Future)

Events to track for analytics:

- `game_started`
- `game_ended` (with score, duration)
- `goal_scored` (with current score)
- `collision` (with defender count, speed)
- `powerup_collected`
- `score_submitted`
- `leaderboard_viewed`
- `settings_changed`

---

## 🔒 Fair Play & Anti-Cheat

**Client Validation**:

- Score cannot exceed realistic limits
- Timestamps checked for validity
- Name length enforced

**Server Validation**:

- Score range checked (0-1000 reasonable)
- Rate limiting on submissions
- Duplicate score detection
- Anomaly detection for impossible scores

**Future Enhancements**:

- Session tokens
- Score verification algorithm
- IP-based rate limiting
- Account system

---

## 🎯 Success Metrics

### Key Performance Indicators (KPIs)

**Engagement**:

- Daily Active Users (DAU)
- Session length
- Retention rate (D1, D7, D30)

**Monetization** (if ads/IAP added):

- ARPU (Average Revenue Per User)
- Conversion rate
- Ad impressions

**Quality**:

- Crash rate
- 5-star reviews
- NPS (Net Promoter Score)

### Target Metrics

- Average session: 3-5 minutes
- D1 retention: >40%
- D7 retention: >20%
- Average score: 5-10 goals
- Leaderboard submission rate: >30%

---

## 🚀 Future Roadmap

### Version 1.1

- [ ] More power-ups
- [ ] Sound effects assets
- [ ] Achievement system
- [ ] Daily challenges

### Version 1.2

- [ ] Multiple game modes
- [ ] Cosmetic unlocks
- [ ] Social sharing
- [ ] Friend challenges

### Version 2.0

- [ ] Story mode
- [ ] Boss defenders
- [ ] Special moves
- [ ] Tournament mode
- [ ] Multiplayer

---

## 📝 Credits & Attribution

**Game Design**: Street Football Rush Team

**Technologies**:

- Flutter/Flame (game engine)
- Go/Fiber (backend)
- Hive (storage)

**Inspiration**:

- Classic arcade games
- Mobile sports games
- Endless runners

---

**Last Updated**: November 19, 2025
**Version**: 1.0.0
