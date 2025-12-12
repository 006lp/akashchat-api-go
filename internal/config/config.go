package config

import (
	"os"
)

// Config holds the application configuration
type Config struct {
	ServerAddress    string
	AkashBaseURL     string
	BearerToken      string
	DefaultTimeout   int
	SessionCacheSize int
}

// Load loads configuration from environment variables with defaults
func Load() *Config {
	cfg := &Config{
		ServerAddress:    getEnv("SERVER_ADDRESS", "localhost:16571"),
		AkashBaseURL:     getEnv("AKASH_BASE_URL", "https://chat.akash.network"),
		BearerToken:      getEnv("BEARER_TOKEN", ""),
		DefaultTimeout:   60,
		SessionCacheSize: 100,
	}

	return cfg
}

// getEnv gets environment variable with default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
