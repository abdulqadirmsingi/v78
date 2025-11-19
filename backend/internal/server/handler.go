package server

import (
	"street-football-rush/backend/internal/config"
	"street-football-rush/backend/internal/leaderboard/usecase"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Handler holds dependencies for HTTP handlers
type Handler struct {
	leaderboardUC *usecase.LeaderboardUseCase
	config        *config.Config
}

// NewHandler creates a new handler instance
func NewHandler(leaderboardUC *usecase.LeaderboardUseCase, cfg *config.Config) *Handler {
	return &Handler{
		leaderboardUC: leaderboardUC,
		config:        cfg,
	}
}

// HealthCheck handles health check requests
func (h *Handler) HealthCheck(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{
		"status":    "ok",
		"timestamp": time.Now().Format(time.RFC3339),
	})
}

// SubmitScoreRequest represents the request body for score submission
type SubmitScoreRequest struct {
	Name  string `json:"name"`
	Score int    `json:"score"`
}

// SubmitScore handles POST /api/v1/score
func (h *Handler) SubmitScore(c *fiber.Ctx) error {
	var req SubmitScoreRequest

	// Parse request body
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request format",
		})
	}

	// Submit score via use case
	score, err := h.leaderboardUC.SubmitScore(req.Name, req.Score)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Return created score
	return c.Status(fiber.StatusCreated).JSON(score)
}

// LeaderboardResponse represents the leaderboard API response
type LeaderboardResponse struct {
	Leaderboard interface{} `json:"leaderboard"`
	Total       int         `json:"total"`
}

// GetLeaderboard handles GET /api/v1/leaderboard
func (h *Handler) GetLeaderboard(c *fiber.Ctx) error {
	// Parse limit query parameter
	limit := c.QueryInt("limit", 10)

	// Get leaderboard
	scores, total, err := h.leaderboardUC.GetLeaderboard(limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve leaderboard",
		})
	}

	// Return response
	return c.JSON(LeaderboardResponse{
		Leaderboard: scores,
		Total:       total,
	})
}

// GameConfigResponse represents the game configuration response
type GameConfigResponse struct {
	InitialDefenders      int     `json:"initial_defenders"`
	DefenderSpeedBase     float64 `json:"defender_speed_base"`
	DefenderSpeedIncr     float64 `json:"defender_speed_increment"`
	PlayerSpeed           float64 `json:"player_speed"`
	FieldWidth            int     `json:"field_width"`
	FieldHeight           int     `json:"field_height"`
}

// GetConfig handles GET /api/v1/config
func (h *Handler) GetConfig(c *fiber.Ctx) error {
	return c.JSON(GameConfigResponse{
		InitialDefenders:      h.config.Game.InitialDefenders,
		DefenderSpeedBase:     h.config.Game.DefenderSpeedBase,
		DefenderSpeedIncr:     h.config.Game.DefenderSpeedIncr,
		PlayerSpeed:           h.config.Game.PlayerSpeed,
		FieldWidth:            h.config.Game.FieldWidth,
		FieldHeight:           h.config.Game.FieldHeight,
	})
}

