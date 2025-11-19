package usecase

import (
	"street-football-rush/backend/internal/leaderboard/repository"
	"testing"
)

func TestSubmitScore(t *testing.T) {
	repo := repository.NewMemoryRepository()
	uc := NewLeaderboardUseCase(repo)

	tests := []struct {
		name      string
		inputName string
		score     int
		wantErr   bool
	}{
		{
			name:      "Valid score submission",
			inputName: "Player1",
			score:     10,
			wantErr:   false,
		},
		{
			name:      "Empty name should fail",
			inputName: "",
			score:     5,
			wantErr:   true,
		},
		{
			name:      "Negative score should fail",
			inputName: "Player2",
			score:     -1,
			wantErr:   true,
		},
		{
			name:      "Zero score is valid",
			inputName: "Player3",
			score:     0,
			wantErr:   false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			score, err := uc.SubmitScore(tt.inputName, tt.score)
			if (err != nil) != tt.wantErr {
				t.Errorf("SubmitScore() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && score == nil {
				t.Error("Expected score to be non-nil")
			}
			if !tt.wantErr && score.Name != tt.inputName {
				t.Errorf("Expected name %s, got %s", tt.inputName, score.Name)
			}
		})
	}
}

func TestGetLeaderboard(t *testing.T) {
	repo := repository.NewMemoryRepository()
	uc := NewLeaderboardUseCase(repo)

	// Submit some test scores
	_ = uc.SubmitScore("Alice", 100)
	_ = uc.SubmitScore("Bob", 200)
	_ = uc.SubmitScore("Charlie", 150)

	tests := []struct {
		name       string
		limit      int
		wantScores int
	}{
		{
			name:       "Get top 3",
			limit:      3,
			wantScores: 3,
		},
		{
			name:       "Get top 2",
			limit:      2,
			wantScores: 2,
		},
		{
			name:       "Default limit (10)",
			limit:      0,
			wantScores: 3,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			scores, total, err := uc.GetLeaderboard(tt.limit)
			if err != nil {
				t.Errorf("GetLeaderboard() error = %v", err)
				return
			}
			if len(scores) != tt.wantScores {
				t.Errorf("Expected %d scores, got %d", tt.wantScores, len(scores))
			}
			if total != 3 {
				t.Errorf("Expected total 3, got %d", total)
			}
			// Check if sorted by score descending
			if len(scores) > 1 && scores[0].Score < scores[1].Score {
				t.Error("Scores not sorted correctly")
			}
		})
	}
}

