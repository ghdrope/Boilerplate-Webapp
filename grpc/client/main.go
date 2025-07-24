package main

// main is the entry point for the gRPC client. It connects to the server,
// sends a HelloRequest with a sample name, and logs the response.
import (
	"context"
	"log"
	"time"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"google.golang.org/grpc"
)

func main() {
	// Establish an insecure connection to the gRPC server.
	conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	// Create a new HelloService client.
	client := pb.NewHelloServiceClient(conn)

	// Create a context with timeout for the request
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	// Call the SayHello RPC method.
	resp, err := client.SayHello(ctx, &pb.HelloRequest{Name: "World"})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}

	log.Printf("Response from server: %s", resp.Message)
}
