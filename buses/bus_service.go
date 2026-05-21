package buses

import (
	"database/sql"
	"net/http"

	"smarttransit/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type BusHandler struct {
	DB *sql.DB
}

func NewBusHandler(db *sql.DB) *BusHandler {
	return &BusHandler{DB: db}
}

// GET /buses
func (h *BusHandler) GetAllBuses(c *gin.Context) {
	rows, err := h.DB.Query(`SELECT id, bus_number, capacity, status, created_at, updated_at FROM buses`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	defer rows.Close()

	var busList []models.Bus
	for rows.Next() {
		var bus models.Bus
		err := rows.Scan(&bus.ID, &bus.BusNumber, &bus.Capacity, &bus.Status, &bus.CreatedAt, &bus.UpdatedAt)
		if err != nil {
			continue
		}
		busList = append(busList, bus)
	}

	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Buses fetched", Data: busList})
}

// POST /buses
func (h *BusHandler) CreateBus(c *gin.Context) {
	var req models.CreateBusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	id := uuid.New().String()
	_, err := h.DB.Exec(`INSERT INTO buses (id, bus_number, capacity) VALUES ($1, $2, $3)`,
		id, req.BusNumber, req.Capacity)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, models.APIResponse{Success: true, Message: "Bus created successfully"})
}

// PUT /buses/:id
func (h *BusHandler) UpdateBus(c *gin.Context) {
	id := c.Param("id")
	var req models.CreateBusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	_, err := h.DB.Exec(`UPDATE buses SET bus_number=$1, capacity=$2, updated_at=NOW() WHERE id=$3`,
		req.BusNumber, req.Capacity, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Bus updated successfully"})
}

// DELETE /buses/:id
func (h *BusHandler) DeleteBus(c *gin.Context) {
	id := c.Param("id")

	_, err := h.DB.Exec(`DELETE FROM buses WHERE id=$1`, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Bus deleted successfully"})
}
