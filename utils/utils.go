package utils

import (
	"database/sql"
	"fmt"
	"log"
	"strconv"
	"time"

	_ "github.com/lib/pq"
)

func ConnectDatabase(databaseURL string, maxConnections string, maxIdleConnections string, connMaxLifetime string) *sql.DB {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	maxConn, _ := strconv.Atoi(maxConnections)
	maxIdle, _ := strconv.Atoi(maxIdleConnections)
	maxLifetime, _ := strconv.Atoi(connMaxLifetime)

	db.SetMaxOpenConns(maxConn)
	db.SetMaxIdleConns(maxIdle)
	db.SetConnMaxLifetime(time.Duration(maxLifetime) * time.Second)

	err = db.Ping()
	if err != nil {
		log.Fatal("Cannot ping database:", err)
	}

	fmt.Println("✅ Database connected successfully!")
	return db
}
