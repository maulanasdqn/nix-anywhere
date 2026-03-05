// Package driver implements the CSI driver for mounting /nix
package driver

import (
	"github.com/container-storage-interface/spec/lib/go/csi"
	"google.golang.org/grpc"
)

const (
	// DriverName is the name of the CSI driver
	DriverName = "nix.mount.csi"
)

// Driver implements the CSI driver
type Driver struct {
	nodeID  string
	version string
	node    *NodeServer
	identity *IdentityServer
}

// NewDriver creates a new CSI driver
func NewDriver(nodeID, version string) *Driver {
	d := &Driver{
		nodeID:  nodeID,
		version: version,
	}
	d.node = NewNodeServer(nodeID)
	d.identity = NewIdentityServer(DriverName, version)
	return d
}

// RegisterServices registers the CSI services with the gRPC server
func (d *Driver) RegisterServices(server *grpc.Server) {
	csi.RegisterIdentityServer(server, d.identity)
	csi.RegisterNodeServer(server, d.node)
}
