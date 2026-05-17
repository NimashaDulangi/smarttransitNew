package middleware

import (
	"database/sql"
	"net/http"
	"time"

	"smarttransit/config"
	"smarttransit/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	DB  *sql.DB
	Cfg *config.Config
}

func NewAuthHandler(db *sql.DB, cfg *config.Config) *AuthHandler {
	return &AuthHandler{DB: db, Cfg: cfg}
}

// POST /auth/register
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Error hashing password"})
		return
	}

	id := uuid.New().String()
	_, err = h.DB.Exec(`INSERT INTO users (id, name, email, password) VALUES ($1, $2, $3, $4)`,
		id, req.Name, req.Email, string(hashedPassword))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Email already exists"})
		return
	}

	c.JSON(http.StatusCreated, models.APIResponse{Success: true, Message: "User registered successfully"})
}

// POST /auth/login
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIResponse{Success: false, Message: err.Error()})
		return
	}

	var user models.User
	err := h.DB.QueryRow(`SELECT id, name, email, password, role FROM users WHERE email = $1`, req.Email).
		Scan(&user.ID, &user.Name, &user.Email, &user.Password, &user.Role)
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.APIResponse{Success: false, Message: "Invalid email or password"})
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.APIResponse{Success: false, Message: "Invalid email or password"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"email":   user.Email,
		"role":    user.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	})

	tokenString, err := token.SignedString([]byte(h.Cfg.JWTSecret))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIResponse{Success: false, Message: "Error generating token"})
		return
	}

	c.JSON(http.StatusOK, models.APIResponse{
		Success: true,
		Message: "Login successful",
		Data:    models.AuthResponse{Token: tokenString, User: user},
	})
}
