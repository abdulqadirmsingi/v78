package main

import (
	"fmt"
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

	// Initialize repository based on configuration
	var repo repository.Repository
	var err error

	switch cfg.Database.Type {
	case "mysql":
		dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true&charset=utf8mb4",
			cfg.Database.User,
			cfg.Database.Password,
			cfg.Database.Host,
			cfg.Database.Port,
			cfg.Database.Database,
		)
		repo, err = repository.NewMySQLRepository(dsn)
		if err != nil {
			log.Fatalf("Failed to initialize MySQL repository: %v", err)
		}
		log.Println("✅ Connected to MySQL database")
		defer func() {
			if mysqlRepo, ok := repo.(*repository.MySQLRepository); ok {
				if err := mysqlRepo.Close(); err != nil {
					log.Printf("Error closing database connection: %v", err)
				}
			}
		}()
	case "memory":
		fallthrough
	default:
		repo = repository.NewMemoryRepository()
		log.Println("✅ Using in-memory storage")
	}

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

