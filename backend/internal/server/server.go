package server

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"street-football-rush/backend/internal/config"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Server wraps the Fiber application
type Server struct {
	app    *fiber.App
	config *config.Config
}

// NewServer creates a new server instance
func NewServer(handler *Handler, cfg *config.Config) *Server {
	app := fiber.New(fiber.Config{
		AppName:      "Street Football Rush API",
		ServerHeader: "StreetFootballRush",
		ErrorHandler: customErrorHandler,
	})

	// Setup routes
	SetupRoutes(app, handler, cfg.CORS.Origins)

	return &Server{
		app:    app,
		config: cfg,
	}
}

// Start runs the HTTP server with graceful shutdown
func (s *Server) Start() error {
	// Channel to listen for interrupt signals
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	// Start server in a goroutine
	go func() {
		addr := fmt.Sprintf(":%s", s.config.Server.Port)
		log.Printf("🚀 Server starting on http://localhost%s", addr)
		log.Printf("📊 Environment: %s", s.config.Server.Env)
		log.Printf("🎮 Game configured with %d initial defenders", s.config.Game.InitialDefenders)

		if err := s.app.Listen(addr); err != nil {
			log.Printf("❌ Server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	<-quit
	log.Println("\n🛑 Shutting down server...")

	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := s.app.ShutdownWithContext(ctx); err != nil {
		return fmt.Errorf("server shutdown error: %w", err)
	}

	log.Println("✅ Server stopped gracefully")
	return nil
}

// customErrorHandler handles errors globally
func customErrorHandler(c *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError

	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}

	return c.Status(code).JSON(fiber.Map{
		"error": err.Error(),
	})
}

