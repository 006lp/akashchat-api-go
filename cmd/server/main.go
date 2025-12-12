package main

import (
	"log"

	"github.com/006lp/akashchat-api-go/internal/config"
	"github.com/006lp/akashchat-api-go/internal/handler"
	"github.com/006lp/akashchat-api-go/internal/service"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize services
	sessionService := service.NewSessionService()
	akashService := service.NewAkashService()

	// Initialize handlers
	chatHandler := handler.NewChatHandler(sessionService, akashService)
	modelHandler := handler.NewModelHandler()

	// Setup Gin router
	r := gin.Default()

	// Setup CORS
	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"},
		AllowHeaders:     []string{"*"},
		ExposeHeaders:    []string{"*"},
		AllowCredentials: true,
	}))

	// Setup routes
	v1 := r.Group("/v1")
	if cfg.BearerToken != "" {
		v1.Use(handler.AuthMiddleware(cfg.BearerToken))
	}
	v1.POST("/chat/completions", chatHandler.ChatCompletions)
	v1.GET("/models", modelHandler.GetModels)

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "akashchat-api-go is running",
		})
	})

	// Start server
	log.Printf("Starting server on %s", cfg.ServerAddress)
	if err := r.Run(cfg.ServerAddress); err != nil {
		log.Fatal("Failed to start server: ", err)
	}
}
