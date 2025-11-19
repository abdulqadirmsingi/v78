package repository

import (
	"database/sql"
	"fmt"
	"street-football-rush/backend/internal/leaderboard/entity"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

// MySQLRepository implements Repository interface with MySQL storage
type MySQLRepository struct {
	db *sql.DB
}

// NewMySQLRepository creates a new MySQL repository
func NewMySQLRepository(dsn string) (*MySQLRepository, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Test connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	// Create table if not exists
	if err := createTable(db); err != nil {
		return nil, fmt.Errorf("failed to create table: %w", err)
	}

	return &MySQLRepository{db: db}, nil
}

// createTable creates the scores table if it doesn't exist
func createTable(db *sql.DB) error {
	query := `
	CREATE TABLE IF NOT EXISTS scores (
		id VARCHAR(36) PRIMARY KEY,
		name VARCHAR(50) NOT NULL,
		score INT NOT NULL,
		created_at DATETIME NOT NULL,
		INDEX idx_score_created (score DESC, created_at ASC)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	`
	_, err := db.Exec(query)
	return err
}

// Save adds a new score to the repository
func (r *MySQLRepository) Save(score *entity.Score) error {
	query := `INSERT INTO scores (id, name, score, created_at) VALUES (?, ?, ?, ?)`
	_, err := r.db.Exec(query, score.ID, score.Name, score.Score, score.CreatedAt)
	return err
}

// GetTopScores retrieves the top N scores
func (r *MySQLRepository) GetTopScores(limit int) ([]entity.Score, error) {
	var query string
	var rows *sql.Rows
	var err error

	if limit > 0 {
		query = `
			SELECT id, name, score, created_at
			FROM scores
			ORDER BY score DESC, created_at ASC
			LIMIT ?
		`
		rows, err = r.db.Query(query, limit)
	} else {
		query = `
			SELECT id, name, score, created_at
			FROM scores
			ORDER BY score DESC, created_at ASC
		`
		rows, err = r.db.Query(query)
	}

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []entity.Score
	rank := 1
	for rows.Next() {
		var score entity.Score
		var createdAtStr string
		if err := rows.Scan(&score.ID, &score.Name, &score.Score, &createdAtStr); err != nil {
			return nil, err
		}
		score.Rank = rank
		rank++
		score.CreatedAt, err = time.Parse("2006-01-02 15:04:05", createdAtStr)
		if err != nil {
			// Try parsing with timezone
			score.CreatedAt, err = time.Parse(time.RFC3339, createdAtStr)
			if err != nil {
				return nil, fmt.Errorf("failed to parse created_at: %w", err)
			}
		}
		scores = append(scores, score)
	}

	return scores, rows.Err()
}

// GetAll retrieves all scores
func (r *MySQLRepository) GetAll() ([]entity.Score, error) {
	query := `
		SELECT id, name, score, created_at
		FROM scores
		ORDER BY score DESC, created_at ASC
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []entity.Score
	rank := 1
	for rows.Next() {
		var score entity.Score
		var createdAtStr string
		if err := rows.Scan(&score.ID, &score.Name, &score.Score, &createdAtStr); err != nil {
			return nil, err
		}
		score.Rank = rank
		rank++
		score.CreatedAt, err = time.Parse("2006-01-02 15:04:05", createdAtStr)
		if err != nil {
			score.CreatedAt, err = time.Parse(time.RFC3339, createdAtStr)
			if err != nil {
				return nil, fmt.Errorf("failed to parse created_at: %w", err)
			}
		}
		scores = append(scores, score)
	}

	return scores, rows.Err()
}

// Count returns the total number of scores
func (r *MySQLRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM scores").Scan(&count)
	return count, err
}

// GetRankForScore returns the rank of a given score value
func (r *MySQLRepository) GetRankForScore(scoreValue int) (int, error) {
	var rank int
	query := `
		SELECT COUNT(*) + 1
		FROM scores
		WHERE score > ?
	`
	err := r.db.QueryRow(query, scoreValue).Scan(&rank)
	return rank, err
}

// Close closes the database connection
func (r *MySQLRepository) Close() error {
	return r.db.Close()
}

