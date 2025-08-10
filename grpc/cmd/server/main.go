// Package main implements the gRPC server entry point for the HelloService.
package main

import (
	"log"
	"net"
	"os"

	proto "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	server "github.com/ghdrope/boilerplate-webapp/grpc/internal/server/handler"

	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

// main starts a gRPC server, registers the HelloService, health check service,
// and optionally enables reflection in development mode.
func main() {
	// Start listening on TCP port 50051.
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// Create a new gRPC server instance.
	s := grpc.NewServer()

	// Register the HelloService implementation.
	proto.RegisterHelloServiceServer(s, &server.HelloServer{})

	// Set up and register the health check service.
	healthServer := health.NewServer()
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
	healthpb.RegisterHealthServer(s, healthServer)

	// Enable gRPC reflection for development environment.
	if os.Getenv("ENV") == "dev" {
		reflection.Register(s)
		log.Println("gRPC reflection enabled (dev environment)")
	} else {
		log.Println("gRPC reflection disabled (non-dev environment)")
	}

	// Start serving gRPC requests.
	log.Println("gRPC server listening on port 50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
