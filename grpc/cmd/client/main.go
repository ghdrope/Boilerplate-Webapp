// Package main implements a gRPC client for the HelloService.
package main

import (
	"context"
	"log"
	"time"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// main is the entry point of the gRPC client application.
// It connects to the gRPC server, sends a SayHello request, and logs the response.
func main() {
	// Create a context with a connection timeout to avoid hanging indefinitely.
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Establish a gRPC connection to the server.
	// The connection is insecure (no TLS) for development purposes.
	conn, err := grpc.DialContext(ctx, "localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithBlock()) //nolint:staticcheck // Blocking dial is acceptable for CLI tools.
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer func() {
		if err := conn.Close(); err != nil {
			log.Printf("error closing connection: %v", err)
		}
	}()

	// Create a new gRPC HelloService client.
	client := pb.NewHelloServiceClient(conn)

	// Create a context for the RPC call with a short timeout.
	rpcCtx, rpcCancel := context.WithTimeout(context.Background(), time.Second)
	defer rpcCancel()

	// Perform the SayHello RPC.
	resp, err := client.SayHello(rpcCtx, &pb.HelloRequest{Name: "World"})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}

	// Log the response from the server
	log.Printf("Response from server: %s", resp.Message)
}
