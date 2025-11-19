package repository

import "street-football-rush/backend/internal/leaderboard/entity"

// Repository defines the interface for score persistence
type Repository interface {
	Save(score *entity.Score) error
	GetTopScores(limit int) ([]entity.Score, error)
	GetAll() ([]entity.Score, error)
	Count() (int, error)
	GetRankForScore(score int) (int, error)
}

