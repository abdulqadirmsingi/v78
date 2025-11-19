package config

import (
	"os"
	"strconv"
)

// Config holds application configuration
type Config struct {
	Server ServerConfig
	Game   GameConfig
	CORS   CORSConfig
}

// ServerConfig holds server-specific configuration
type ServerConfig struct {
	Port     string
	Env      string
	LogLevel string
}

// GameConfig holds game-specific configuration
type GameConfig struct {
	InitialDefenders      int
	DefenderSpeedBase     float64
	DefenderSpeedIncr     float64
	PlayerSpeed           float64
	FieldWidth            int
	FieldHeight           int
}

// CORSConfig holds CORS configuration
type CORSConfig struct {
	Origins string
}

// Load reads configuration from environment variables
func Load() *Config {
	return &Config{
		Server: ServerConfig{
			Port:     getEnv("PORT", "8080"),
			Env:      getEnv("ENV", "development"),
			LogLevel: getEnv("LOG_LEVEL", "info"),
		},
		Game: GameConfig{
			InitialDefenders:      getEnvAsInt("INITIAL_DEFENDERS", 3),
			DefenderSpeedBase:     getEnvAsFloat("DEFENDER_SPEED_BASE", 100.0),
			DefenderSpeedIncr:     getEnvAsFloat("DEFENDER_SPEED_INCREMENT", 10.0),
			PlayerSpeed:           getEnvAsFloat("PLAYER_SPEED", 150.0),
			FieldWidth:            getEnvAsInt("FIELD_WIDTH", 800),
			FieldHeight:           getEnvAsInt("FIELD_HEIGHT", 1200),
		},
		CORS: CORSConfig{
			Origins: getEnv("CORS_ORIGINS", "*"),
		},
	}
}

// getEnv reads an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvAsInt reads an environment variable as int or returns a default value
func getEnvAsInt(key string, defaultValue int) int {
	valueStr := getEnv(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}

// getEnvAsFloat reads an environment variable as float64 or returns a default value
func getEnvAsFloat(key string, defaultValue float64) float64 {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseFloat(valueStr, 64); err == nil {
		return value
	}
	return defaultValue
}

