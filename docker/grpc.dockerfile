#
# ----- Stage 1: Build -----
#
FROM golang:1.24-alpine AS builder

# Install git for module fetching and build dependencies
RUN apk add --no-cache git build-base

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to leverage Docker cache for dependencies
COPY grpc/go.mod grpc/go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the server source code
COPY grpc/server ./server
COPY grpc/gen ./gen
COPY grpc/proto ./proto

# Build the Go binary with static linking and no cgo for portability
WORKDIR /app/server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o grpc-server main.go



#
# ----- Stage 2: Run -----
#
FROM alpine:3.21

# Install certificates and wget for grpc_health_probe
RUN apk --no-cache add ca-certificates wget

# Download latest grpc_health_probe binary
RUN wget -qO /usr/local/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.38/grpc_health_probe-linux-amd64 && \
    chmod +x /usr/local/bin/grpc_health_probe

# Set working directory
WORKDIR /app

# Copy built binary from builder stage
COPY --from=builder /app/server/grpc-server .

# Expose gRPC port
EXPOSE 50051

# Run the binary
CMD ["./grpc-server"]