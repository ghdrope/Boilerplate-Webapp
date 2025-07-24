// Package main starts a gRPC server that implements the HelloService.
package main

import (
	"context"
	"log"
	"net"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"google.golang.org/grpc"
)

// server is an implementation of the HelloService gRPC server.
type server struct {
	pb.UnimplementedHelloServiceServer
}

// SayHello handles incoming HelloRequests and returns a greeting.
func (s *server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	return &pb.HelloResponse{
		Message: "Hello " + req.Name,
	}, nil
}

// main starts the gRPC server and listens for incoming connections.
func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterHelloServiceServer(s, &server{})

	log.Println("gRPC server listening on port 50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
