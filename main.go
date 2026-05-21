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

	cfg := config.LoadConfig()

	db := utils.ConnectDatabase(
		cfg.DatabaseURL,
		cfg.DatabaseMaxConnections,
		cfg.DatabaseMaxIdleConnections,
		cfg.DatabaseConnMaxLifetime,
	)
	defer db.Close()

	router := gin.Default()

	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	authHandler := middleware.NewAuthHandler(db, cfg)
	busHandler := buses.NewBusHandler(db)
	routeHandler := routes.NewRouteHandler(db)
	bookingHandler := booking.NewBookingHandler(db)

	api := router.Group("/api")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
		}
	}

	protected := router.Group("/api")
	protected.Use(middleware.AuthMiddleware(cfg))
	{
		// Bus CRUD
		protected.GET("/buses", busHandler.GetAllBuses)
		protected.POST("/buses", busHandler.CreateBus)
		protected.PUT("/buses/:id", busHandler.UpdateBus)
		protected.DELETE("/buses/:id", busHandler.DeleteBus)

		// Route CRUD
		protected.GET("/routes", routeHandler.GetAllRoutes)
		protected.POST("/routes", routeHandler.CreateRoute)
		protected.PUT("/routes/:id", routeHandler.UpdateRoute)
		protected.DELETE("/routes/:id", routeHandler.DeleteRoute)

		// Booking CRUD
		protected.GET("/bookings", bookingHandler.GetAllBookings)
		protected.POST("/bookings", bookingHandler.CreateBooking)
		protected.PUT("/bookings/:id", bookingHandler.UpdateBooking)
		protected.DELETE("/bookings/:id", bookingHandler.DeleteBooking)
	}

	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "SmartTransit API is running!"})
	})

	fmt.Println("🚀 SmartTransit API running on port", cfg.Port)
	router.Run(":" + cfg.Port)
}
