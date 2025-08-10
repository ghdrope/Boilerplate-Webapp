// Package handler contains the gRPC service implementations for the HelloService.
package handler

import (
	"context"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
)

// HelloServer implements the HelloService gRPC server.
type HelloServer struct {
	pb.UnimplementedHelloServiceServer
}

// SayHello handles the incoming HelloRequest and returns a HelloResponse.
// It responds with a greeting message that includes the provided name.
//
// ctx: request context.
// req: the HelloRequest containing the name to greet.
//
// Returns:
//   - HelloResponse with a message "Hello <name>".
//   - error if there is a problem handling the request.
func (s *HelloServer) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	return &pb.HelloResponse{Message: "Hello " + req.GetName()}, nil
}
