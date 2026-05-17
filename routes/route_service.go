package routes

import (
	"database/sql"
	"net/http"

	"smarttransit/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type RouteHandler struct {
	DB *sql.DB
}

func NewRouteHandler(db *sql.DB) *RouteHandler {
	return &RouteHandler{DB: db}
}

// GET /routes
func (h *RouteHandler) GetAllRoutes(c *gin.Context) {
	rows, err := h.DB.Query(`SELECT id, route_name, start_location, end_location, distance_km, status, created_at, updated_at FROM routes`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	defer rows.Close()

	var routeList []models.Route
	for rows.Next() {
		var route models.Route
		err := rows.Scan(&route.ID, &route.RouteName, &route.StartLocation, &route.EndLocation, &route.DistanceKm, &route.Status, &route.CreatedAt, &route.UpdatedAt)
		if err != nil {
			continue
		}
		routeList = append(routeList, route)
	}

	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Routes fetched", Data: routeList})
}

// POST /routes
func (h *RouteHandler) CreateRoute(c *gin.Context) {
	var req models.CreateRouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	id := uuid.New().String()
	_, err := h.DB.Exec(`INSERT INTO routes (id, route_name, start_location, end_location, distance_km) VALUES ($1, $2, $3, $4, $5)`,
		id, req.RouteName, req.StartLocation, req.EndLocation, req.DistanceKm)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, models.APIResponse{Success: true, Message: "Route created successfully"})
}
