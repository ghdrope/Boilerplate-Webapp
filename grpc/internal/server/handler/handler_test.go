// Package handler contains unit tests for the HelloService implementation.
package handler

import (
	"context"
	"testing"

	pb "github.com/ghdrope/boilerplate-webapp/grpc/gen/proto"
)

// TestSayHello verifies that the SayHello method returns the expected greeting
// message without errors.
func TestSayHello(t *testing.T) {
	s := &HelloServer{}

	req := &pb.HelloRequest{Name: "Test"}
	resp, err := s.SayHello(context.Background(), req)
	if err != nil {
		t.Fatalf("SayHello returned error: %v", err)
	}

	expected := "Hello Test"
	if resp.Message != expected {
		t.Errorf("Got %q, want %q", resp.Message, expected)
	}
}
