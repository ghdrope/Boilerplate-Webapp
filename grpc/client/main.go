package main

import (
	"context"
	"log"
	"time"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// main connects to the gRPC server, sends a HelloRequest, and logs the response.
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Establish a connection to the gRPC server with insecure credentials.
	// grpc.DialContext is currently deprecated but still the recommended approach; suppress lint warning.
	conn, err := grpc.DialContext(ctx, "localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithBlock()) //nolint:staticcheck
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer func() {
		if err := conn.Close(); err != nil {
			log.Printf("error closing connection: %v", err)
		}
	}()

	client := pb.NewHelloServiceClient(conn)

	// Create a short-lived context for the RPC call.
	rpcCtx, rpcCancel := context.WithTimeout(context.Background(), time.Second)
	defer rpcCancel()

	// Perform the SayHello RPC call.
	resp, err := client.SayHello(rpcCtx, &pb.HelloRequest{Name: "World"})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}

	log.Printf("Response from server: %s", resp.Message)
}
