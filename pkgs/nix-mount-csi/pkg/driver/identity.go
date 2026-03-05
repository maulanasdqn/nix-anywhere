package driver

import (
	"context"

	"github.com/container-storage-interface/spec/lib/go/csi"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// IdentityServer implements the CSI Identity service
type IdentityServer struct {
	csi.UnimplementedIdentityServer
	name    string
	version string
}

// NewIdentityServer creates a new Identity server
func NewIdentityServer(name, version string) *IdentityServer {
	return &IdentityServer{
		name:    name,
		version: version,
	}
}

// GetPluginInfo returns the name and version of the plugin
func (s *IdentityServer) GetPluginInfo(ctx context.Context, req *csi.GetPluginInfoRequest) (*csi.GetPluginInfoResponse, error) {
	return &csi.GetPluginInfoResponse{
		Name:          s.name,
		VendorVersion: s.version,
	}, nil
}

// GetPluginCapabilities returns the capabilities of the plugin
func (s *IdentityServer) GetPluginCapabilities(ctx context.Context, req *csi.GetPluginCapabilitiesRequest) (*csi.GetPluginCapabilitiesResponse, error) {
	return &csi.GetPluginCapabilitiesResponse{
		Capabilities: []*csi.PluginCapability{},
	}, nil
}

// Probe checks if the plugin is healthy
func (s *IdentityServer) Probe(ctx context.Context, req *csi.ProbeRequest) (*csi.ProbeResponse, error) {
	return &csi.ProbeResponse{
		Ready: wrapperspb.Bool(true),
	}, nil
}
