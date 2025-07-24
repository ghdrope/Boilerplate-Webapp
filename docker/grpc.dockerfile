#
# ----- Stage 1: Build -----
#
FROM golang:1.23 as builder

# Set the working directory inside the container
WORKDIR /grpc

# Copy go.mod and go.sum
COPY grpc/go.mod grpc/go.sum ./

# Download dependencies
RUN go mod download

# Copy only the server code and shared code
COPY grpc/server ./server
COPY grpc/gen ./gen
COPY grpc/proto ./proto

# Build the Go binary
WORKDIR /grpc/server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o grpc-server main.go

#
# ----- Stage 2: Run -----
#
FROM alpine:latest

# Install certificates (needed for many gRPC setups)
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /grpc

# Copy built binary from builder stage
COPY --from=builder /grpc/server/grpc-server .

# Expose gRPC port
EXPOSE 50051

# Run the binary
CMD ["./grpc-server"]