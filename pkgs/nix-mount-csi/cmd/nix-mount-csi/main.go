// nix-mount-csi - A simple CSI driver for mounting /nix into Kubernetes pods
//
// This driver enables pods to access the host's Nix store directly,
// allowing them to run binaries from /nix/store without container images.
package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/msdqn/nix-mount-csi/pkg/driver"
	"google.golang.org/grpc"
	"k8s.io/klog/v2"
)

var (
	endpoint = flag.String("endpoint", "unix:///csi/csi.sock", "CSI endpoint")
	nodeID   = flag.String("nodeid", "", "Node ID")
	version  = "0.1.0"
)

func main() {
	klog.InitFlags(nil)
	flag.Parse()

	if *nodeID == "" {
		hostname, err := os.Hostname()
		if err != nil {
			klog.Fatalf("Failed to get hostname: %v", err)
		}
		*nodeID = hostname
	}

	klog.Infof("Starting nix-mount-csi driver version %s", version)
	klog.Infof("Node ID: %s", *nodeID)
	klog.Infof("Endpoint: %s", *endpoint)

	// Create the driver
	d := driver.NewDriver(*nodeID, version)

	// Parse endpoint
	proto, addr, err := parseEndpoint(*endpoint)
	if err != nil {
		klog.Fatalf("Failed to parse endpoint: %v", err)
	}

	// Clean up socket if it exists
	if proto == "unix" {
		if err := os.Remove(addr); err != nil && !os.IsNotExist(err) {
			klog.Fatalf("Failed to remove socket: %v", err)
		}
	}

	// Create listener
	listener, err := net.Listen(proto, addr)
	if err != nil {
		klog.Fatalf("Failed to listen: %v", err)
	}

	// Create gRPC server
	server := grpc.NewServer()
	d.RegisterServices(server)

	// Handle shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigChan
		klog.Info("Received shutdown signal")
		server.GracefulStop()
	}()

	klog.Infof("Listening on %s", *endpoint)
	if err := server.Serve(listener); err != nil {
		klog.Fatalf("Failed to serve: %v", err)
	}
}

func parseEndpoint(endpoint string) (string, string, error) {
	if len(endpoint) > 7 && endpoint[:7] == "unix://" {
		return "unix", endpoint[7:], nil
	}
	if len(endpoint) > 6 && endpoint[:6] == "tcp://" {
		return "tcp", endpoint[6:], nil
	}
	return "", "", fmt.Errorf("invalid endpoint: %s", endpoint)
}
