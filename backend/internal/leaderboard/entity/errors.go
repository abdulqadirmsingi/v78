package entity

import "errors"

var (
	// ErrInvalidName is returned when the player name is empty
	ErrInvalidName = errors.New("player name cannot be empty")

	// ErrNameTooLong is returned when the player name exceeds maximum length
	ErrNameTooLong = errors.New("player name too long (max 50 characters)")

	// ErrInvalidScore is returned when the score is negative
	ErrInvalidScore = errors.New("score cannot be negative")

	// ErrScoreNotFound is returned when a score is not found
	ErrScoreNotFound = errors.New("score not found")
)

