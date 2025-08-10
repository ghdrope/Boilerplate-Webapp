// Package server contains integration tests for the gRPC HelloService server.
package server

import (
	"context"
	"net"
	"testing"
	"time"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
	"github.com/ghdrope/boilerplate-webapp/grpc/internal/server/handler"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// startTestServer starts a gRPC HelloService server for integration testing.
// It binds to a random available port on localhost to avoid conflicts.
//
// t: the testing object for logging and error handling.
//
// Returns:
//   - *grpc.Server: the started gRPC server instance.
//   - net.Listener: the listener where the server is bound.
//
// Note: The caller is responsible for stopping the server using s.Stop().
func startTestServer(t *testing.T) (*grpc.Server, net.Listener) {
	lis, err := net.Listen("tcp", "localhost:0") // bind to a random free port
	if err != nil {
		t.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterHelloServiceServer(s, &handler.HelloServer{}) // register the HelloService handler

	go func() {
		if err := s.Serve(lis); err != nil {
			t.Logf("server stopped: %v", err)
		}
	}()

	return s, lis
}

// TestIntegrationSayHello verifies that the HelloService SayHello method works
// end-to-end by starting a gRPC server, connecting a client, and checking the response.
//
// Steps:
//  1. Start the HelloService server on a random port.
//  2. Connect a gRPC client to that server.
//  3. Send a HelloRequest.
//  4. Verify the HelloResponse message matches the expected output.
//
// This test ensures that the server and client communicate correctly over gRPC.
func TestIntegrationSayHello(t *testing.T) {
	s, lis := startTestServer(t)
	defer s.Stop()

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	// Dial the test server
	conn, err := grpc.DialContext(ctx, lis.Addr().String(), grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithBlock()) //nolint:staticcheck // Blocking dial is acceptable for CLI tools.
	if err != nil {
		t.Fatalf("did not connect: %v", err)
	}
	defer conn.Close() //nolint:errcheck // ignore close error in tests

	client := pb.NewHelloServiceClient(conn)

	// Perform the SayHello RPC
	resp, err := client.SayHello(ctx, &pb.HelloRequest{Name: "Integration Test"})
	if err != nil {
		t.Fatalf("SayHello failed: %v", err)
	}

	// Verify the response
	want := "Hello Integration Test"
	if resp.Message != want {
		t.Errorf("Got %q, want %q", resp.Message, want)
	}
}
