package main

import (
	"fmt"

	"smarttransit/booking"
	"smarttransit/buses"
	"smarttransit/config"
	"smarttransit/middleware"
	"smarttransit/routes"
	"smarttransit/utils"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	fmt.Println("🚌 SmartTransit is starting...")

	// Load config
	cfg := config.LoadConfig()

	// Connect to database
	db := utils.ConnectDatabase(
		cfg.DatabaseURL,
		cfg.DatabaseMaxConnections,
		cfg.DatabaseMaxIdleConnections,
		cfg.DatabaseConnMaxLifetime,
	)
	defer db.Close()

	// Setup Gin router
	router := gin.Default()

	// CORS middleware
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	// Initialize handlers
	authHandler := middleware.NewAuthHandler(db, cfg)
	busHandler := buses.NewBusHandler(db)
	routeHandler := routes.NewRouteHandler(db)
	bookingHandler := booking.NewBookingHandler(db)

	// Public routes (no auth needed)
	api := router.Group("/api")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
		}
	}

	// Protected routes (auth required)
	protected := router.Group("/api")
	protected.Use(middleware.AuthMiddleware(cfg))
	{
		// Bus routes
		protected.GET("/buses", busHandler.GetAllBuses)
		protected.POST("/buses", busHandler.CreateBus)

		// Route routes
		protected.GET("/routes", routeHandler.GetAllRoutes)
		protected.POST("/routes", routeHandler.CreateRoute)

		// Booking routes
		protected.GET("/bookings", bookingHandler.GetAllBookings)
		protected.POST("/bookings", bookingHandler.CreateBooking)
	}

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "SmartTransit API is running!"})
	})

	fmt.Println("🚀 SmartTransit API running on port", cfg.Port)
	router.Run(":" + cfg.Port)
}
