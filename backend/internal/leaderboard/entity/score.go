package entity

import (
	"time"
)

// Score represents a player's game score entry
type Score struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Score     int       `json:"score"`
	Rank      int       `json:"rank"`
	CreatedAt time.Time `json:"created_at"`
}

// NewScore creates a new score entry
func NewScore(id, name string, score int) *Score {
	return &Score{
		ID:        id,
		Name:      name,
		Score:     score,
		CreatedAt: time.Now(),
	}
}

// Validate checks if the score entry is valid
func (s *Score) Validate() error {
	if s.Name == "" {
		return ErrInvalidName
	}
	if len(s.Name) > 50 {
		return ErrNameTooLong
	}
	if s.Score < 0 {
		return ErrInvalidScore
	}
	return nil
}

