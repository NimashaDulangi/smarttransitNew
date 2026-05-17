package booking

import (
	"database/sql"
	"net/http"

	"smarttransit/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type BookingHandler struct {
	DB *sql.DB
}

func NewBookingHandler(db *sql.DB) *BookingHandler {
	return &BookingHandler{DB: db}
}

// GET /bookings
func (h *BookingHandler) GetAllBookings(c *gin.Context) {
	rows, err := h.DB.Query(`SELECT id, bus_id, route_id, passenger_name, passenger_phone, seat_number, status, created_at, updated_at FROM bookings`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	defer rows.Close()

	var bookingList []models.Booking
	for rows.Next() {
		var b models.Booking
		err := rows.Scan(&b.ID, &b.BusID, &b.RouteID, &b.PassengerName, &b.PassengerPhone, &b.SeatNumber, &b.Status, &b.CreatedAt, &b.UpdatedAt)
		if err != nil {
			continue
		}
		bookingList = append(bookingList, b)
	}

	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Bookings fetched", Data: bookingList})
}

// POST /bookings
func (h *BookingHandler) CreateBooking(c *gin.Context) {
	var req models.CreateBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	id := uuid.New().String()
	_, err := h.DB.Exec(`INSERT INTO bookings (id, bus_id, route_id, passenger_name, passenger_phone, seat_number) VALUES ($1, $2, $3, $4, $5, $6)`,
		id, req.BusID, req.RouteID, req.PassengerName, req.PassengerPhone, req.SeatNumber)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, models.APIResponse{Success: true, Message: "Booking created successfully"})
}
