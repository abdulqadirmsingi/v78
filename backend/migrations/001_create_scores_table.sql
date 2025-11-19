-- Migration: Create scores table
-- This table stores player scores for the leaderboard

CREATE TABLE IF NOT EXISTS scores (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    score INT NOT NULL,
    created_at DATETIME NOT NULL,
    INDEX idx_score_created (score DESC, created_at ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Example data (optional, for testing):
-- INSERT INTO scores (id, name, score, created_at) VALUES
-- ('550e8400-e29b-41d4-a716-446655440000', 'Player1', 100, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440001', 'Player2', 85, NOW()),
-- ('550e8400-e29b-41d4-a716-446655440002', 'Player3', 120, NOW());

