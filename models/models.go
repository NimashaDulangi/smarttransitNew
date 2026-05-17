package models

import "time"

type User struct {
	ID        string    `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	Password  string    `json:"-" db:"password"`
	Role      string    `json:"role" db:"role"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type Bus struct {
	ID        string    `json:"id" db:"id"`
	BusNumber string    `json:"bus_number" db:"bus_number"`
	Capacity  int       `json:"capacity" db:"capacity"`
	Status    string    `json:"status" db:"status"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type Route struct {
	ID            string    `json:"id" db:"id"`
	RouteName     string    `json:"route_name" db:"route_name"`
	StartLocation string    `json:"start_location" db:"start_location"`
	EndLocation   string    `json:"end_location" db:"end_location"`
	DistanceKm    float64   `json:"distance_km" db:"distance_km"`
	Status        string    `json:"status" db:"status"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
}

type Booking struct {
	ID             string    `json:"id" db:"id"`
	BusID          string    `json:"bus_id" db:"bus_id"`
	RouteID        string    `json:"route_id" db:"route_id"`
	PassengerName  string    `json:"passenger_name" db:"passenger_name"`
	PassengerPhone string    `json:"passenger_phone" db:"passenger_phone"`
	SeatNumber     int       `json:"seat_number" db:"seat_number"`
	Status         string    `json:"status" db:"status"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
}

type RegisterRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type CreateBusRequest struct {
	BusNumber string `json:"bus_number" binding:"required"`
	Capacity  int    `json:"capacity" binding:"required"`
}

type CreateRouteRequest struct {
	RouteName     string  `json:"route_name" binding:"required"`
	StartLocation string  `json:"start_location" binding:"required"`
	EndLocation   string  `json:"end_location" binding:"required"`
	DistanceKm    float64 `json:"distance_km"`
}

type CreateBookingRequest struct {
	BusID          string `json:"bus_id" binding:"required"`
	RouteID        string `json:"route_id" binding:"required"`
	PassengerName  string `json:"passenger_name" binding:"required"`
	PassengerPhone string `json:"passenger_phone"`
	SeatNumber     int    `json:"seat_number"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}
