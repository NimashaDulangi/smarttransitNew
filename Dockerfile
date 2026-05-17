# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o smarttransit .

# Run stage
FROM alpine:latest

# Create non-root user (required by Choreo)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/smarttransit .

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER 10014

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./smarttransit"]