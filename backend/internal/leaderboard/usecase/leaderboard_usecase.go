package usecase

import (
	"street-football-rush/backend/internal/leaderboard/entity"
	"street-football-rush/backend/internal/leaderboard/repository"

	"github.com/google/uuid"
)

// LeaderboardUseCase handles business logic for leaderboard operations
type LeaderboardUseCase struct {
	repo repository.Repository
}

// NewLeaderboardUseCase creates a new leaderboard use case
func NewLeaderboardUseCase(repo repository.Repository) *LeaderboardUseCase {
	return &LeaderboardUseCase{
		repo: repo,
	}
}

// SubmitScore validates and saves a new score
func (uc *LeaderboardUseCase) SubmitScore(name string, score int) (*entity.Score, error) {
	// Create new score with UUID
	id := uuid.New().String()
	newScore := entity.NewScore(id, name, score)

	// Validate
	if err := newScore.Validate(); err != nil {
		return nil, err
	}

	// Save to repository
	if err := uc.repo.Save(newScore); err != nil {
		return nil, err
	}

	// Get rank for this score
	rank, err := uc.repo.GetRankForScore(score)
	if err != nil {
		rank = 0
	}
	newScore.Rank = rank

	return newScore, nil
}

// GetLeaderboard retrieves the top scores with a limit
func (uc *LeaderboardUseCase) GetLeaderboard(limit int) ([]entity.Score, int, error) {
	// Default limit
	if limit <= 0 {
		limit = 10
	}

	// Max limit
	if limit > 100 {
		limit = 100
	}

	// Get top scores
	scores, err := uc.repo.GetTopScores(limit)
	if err != nil {
		return nil, 0, err
	}

	// Get total count
	total, err := uc.repo.Count()
	if err != nil {
		total = 0
	}

	return scores, total, nil
}

// GetAllScores retrieves all scores (for admin purposes)
func (uc *LeaderboardUseCase) GetAllScores() ([]entity.Score, error) {
	return uc.repo.GetAll()
}

