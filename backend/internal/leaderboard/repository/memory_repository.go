package repository

import (
	"sort"
	"street-football-rush/backend/internal/leaderboard/entity"
	"sync"
)

// MemoryRepository implements Repository interface with in-memory storage
type MemoryRepository struct {
	scores []entity.Score
	mu     sync.RWMutex
}

// NewMemoryRepository creates a new in-memory repository
func NewMemoryRepository() *MemoryRepository {
	return &MemoryRepository{
		scores: make([]entity.Score, 0),
	}
}

// Save adds a new score to the repository
func (r *MemoryRepository) Save(score *entity.Score) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.scores = append(r.scores, *score)
	return nil
}

// GetTopScores retrieves the top N scores
func (r *MemoryRepository) GetTopScores(limit int) ([]entity.Score, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	// Create a copy to avoid modifying original
	scoresCopy := make([]entity.Score, len(r.scores))
	copy(scoresCopy, r.scores)

	// Sort by score (descending), then by date (ascending)
	sort.Slice(scoresCopy, func(i, j int) bool {
		if scoresCopy[i].Score != scoresCopy[j].Score {
			return scoresCopy[i].Score > scoresCopy[j].Score
		}
		return scoresCopy[i].CreatedAt.Before(scoresCopy[j].CreatedAt)
	})

	// Assign ranks
	for i := range scoresCopy {
		scoresCopy[i].Rank = i + 1
	}

	// Limit results
	if limit > 0 && len(scoresCopy) > limit {
		scoresCopy = scoresCopy[:limit]
	}

	return scoresCopy, nil
}

// GetAll retrieves all scores
func (r *MemoryRepository) GetAll() ([]entity.Score, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	scoresCopy := make([]entity.Score, len(r.scores))
	copy(scoresCopy, r.scores)

	return scoresCopy, nil
}

// Count returns the total number of scores
func (r *MemoryRepository) Count() (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	return len(r.scores), nil
}

// GetRankForScore returns the rank of a given score value
func (r *MemoryRepository) GetRankForScore(scoreValue int) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	rank := 1
	for _, s := range r.scores {
		if s.Score > scoreValue {
			rank++
		}
	}

	return rank, nil
}

