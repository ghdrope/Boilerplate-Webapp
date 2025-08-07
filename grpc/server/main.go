// Package main starts a gRPC server that implements the HelloService.
package main

import (
	"context"
	"log"
	"net"
	"os"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

// server is an implementation of the HelloService gRPC server.
type server struct {
	pb.UnimplementedHelloServiceServer
}

// SayHello handles incoming HelloRequests and returns a greeting.
func (s *server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	return &pb.HelloResponse{Message: "Hello " + req.Name}, nil
}

// main starts the gRPC server and listens for incoming connections.
func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterHelloServiceServer(s, &server{})

	healthServer := health.NewServer()
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
	healthpb.RegisterHealthServer(s, healthServer)

	if os.Getenv("ENV") == "dev" {
		reflection.Register(s)
		log.Println("gRPC reflection enabled (dev environment)")
	} else {
		log.Println("gRPC reflection disabled (non-dev environment)")
	}

	log.Println("gRPC server listening on port 50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
