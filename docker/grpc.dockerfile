#
# ----- Stage 1: Build the gRPC server -----
#
FROM golang:1.24-alpine AS builder

# Install git for Go module fetching and build-base for compiling dependencies
RUN apk add --no-cache git build-base


# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to leverage Docker layer caching for dependencies
COPY grpc/go.mod grpc/go.sum ./

# Download Go dependencies
RUN go mod download

# Copy the rest of the gRPC source code (cmd, internal, gen, proto)
COPY grpc/cmd ./cmd
COPY grpc/internal ./internal
COPY grpc/gen ./gen
COPY grpc/proto ./proto

# Build the gRPC server binary for Linux with static linking (no CGO)
WORKDIR /app/cmd/server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/grpc-server main.go



#
# ----- Stage 2: Runtime container -----
#
FROM alpine:3.21

# Install CA certificates (for TLS) and wget (to fetch health probe)
RUN apk --no-cache add ca-certificates wget

# Download the latest gRPC health probe binary
RUN wget -qO /usr/local/bin/grpc_health_probe \
    https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.38/grpc_health_probe-linux-amd64 && \
    chmod +x /usr/local/bin/grpc_health_probe

# Create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory inside the runtime container
WORKDIR /app

# Copy built binary from the builder stage
COPY --from=builder /app/grpc-server .

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Expose the default gRPC server port
EXPOSE 50051

# Add HEALTHCHECK using gRPC health probe
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD grpc_health_probe -addr=localhost:50051 || exit 1

# Run as non-root user
USER appuser

# Run the gRPC server binary
CMD ["./grpc-server"]