# Street Football Rush - Backend API

Go backend server providing REST API for the Street Football Rush game.

## Features

- **RESTful API** with Fiber framework
- **Clean Architecture** (Entity, Repository, Use Case, Handler)
- **In-memory database** (easily extensible to PostgreSQL)
- **CORS enabled** for cross-origin requests
- **Graceful shutdown** handling
- **Environment-based configuration**
- **Health check endpoint**
- **Unit tests** for business logic

## API Endpoints

### Health Check

```
GET /health
```

### Submit Score

```
POST /api/v1/score
Content-Type: application/json

{
  "name": "PlayerName",
  "score": 15
}
```

### Get Leaderboard

```
GET /api/v1/leaderboard?limit=10
```

### Get Game Configuration

```
GET /api/v1/config
```

## Quick Start

1. **Install dependencies**:

```bash
go mod download
```

2. **Run the server**:

```bash
go run cmd/server/main.go
```

3. **Run tests**:

```bash
go test ./... -v
```

## Docker

Build and run with Docker:

```bash
docker build -t street-football-api .
docker run -p 8080:8080 street-football-api
```

## Configuration

Edit `.env` file to customize settings:

```env
PORT=8080
ENV=development
INITIAL_DEFENDERS=3
DEFENDER_SPEED_BASE=100.0
PLAYER_SPEED=150.0
```

## Project Structure

```
backend/
├── cmd/
│   └── server/
│       └── main.go          # Application entry point
├── internal/
│   ├── config/              # Configuration loading
│   ├── leaderboard/
│   │   ├── entity/          # Domain models
│   │   ├── repository/      # Data access layer
│   │   └── usecase/         # Business logic
│   └── server/              # HTTP handlers & routing
├── pkg/                     # Shared packages
├── go.mod
└── .env
```

## License

MIT
