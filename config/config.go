package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DatabaseURL                string
	DatabaseMaxConnections     string
	DatabaseMaxIdleConnections string
	DatabaseConnMaxLifetime    string
	Port                       string
	JWTSecret                  string
	AppEnv                     string
}

func LoadConfig() *Config {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using environment variables")
	}

	return &Config{
		DatabaseURL:                getEnv("DATABASE_URL", ""),
		DatabaseMaxConnections:     getEnv("DATABASE_MAX_CONNECTIONS", "10"),
		DatabaseMaxIdleConnections: getEnv("DATABASE_MAX_IDLE_CONNECTIONS", "5"),
		DatabaseConnMaxLifetime:    getEnv("DATABASE_CONN_MAX_LIFETIME", "300"),
		Port:                       getEnv("PORT", "8080"),
		JWTSecret:                  getEnv("JWT_SECRET", "secret"),
		AppEnv:                     getEnv("APP_ENV", "dev"),
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
