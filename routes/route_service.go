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

func (h *RouteHandler) GetAllRoutes(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, route_name, start_location, end_location, distance_km, status, created_at, updated_at FROM routes")
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

func (h *RouteHandler) CreateRoute(c *gin.Context) {
	var req models.CreateRouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	id := uuid.New().String()
	_, err := h.DB.Exec("INSERT INTO routes (id, route_name, start_location, end_location, distance_km) VALUES ($1, $2, $3, $4, $5)",
		id, req.RouteName, req.StartLocation, req.EndLocation, req.DistanceKm)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	c.JSON(http.StatusCreated, models.APIResponse{Success: true, Message: "Route created successfully"})
}

func (h *RouteHandler) UpdateRoute(c *gin.Context) {
	id := c.Param("id")
	var req models.CreateRouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	_, err := h.DB.Exec("UPDATE routes SET route_name=$1, start_location=$2, end_location=$3, distance_km=$4, updated_at=NOW() WHERE id=$5",
		req.RouteName, req.StartLocation, req.EndLocation, req.DistanceKm, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Route updated successfully"})
}

func (h *RouteHandler) DeleteRoute(c *gin.Context) {
	id := c.Param("id")
	_, err := h.DB.Exec("DELETE FROM routes WHERE id=$1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: err.Error()})
		return
	}
	c.JSON(http.StatusOK, models.APIResponse{Success: true, Message: "Route deleted successfully"})
}
