package main

import (
	"log"
	"street-football-rush/backend/internal/config"
	"street-football-rush/backend/internal/leaderboard/repository"
	"street-football-rush/backend/internal/leaderboard/usecase"
	"street-football-rush/backend/internal/server"

	"github.com/joho/godotenv"
)

func main() {
	// Load .env file (ignore error if not present)
	_ = godotenv.Load()

	// Load configuration
	cfg := config.Load()

	// Initialize repository
	repo := repository.NewMemoryRepository()

	// Initialize use cases
	leaderboardUC := usecase.NewLeaderboardUseCase(repo)

	// Initialize handler
	handler := server.NewHandler(leaderboardUC, cfg)

	// Create and start server
	srv := server.NewServer(handler, cfg)
	if err := srv.Start(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

