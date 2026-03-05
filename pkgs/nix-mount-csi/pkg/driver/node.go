package driver

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/container-storage-interface/spec/lib/go/csi"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"k8s.io/klog/v2"
	"k8s.io/mount-utils"
)

// NodeServer implements the CSI Node service
type NodeServer struct {
	csi.UnimplementedNodeServer
	nodeID     string
	mounter    mount.Interface
	buildCache map[string]string // flakeRef -> storePath cache
	cacheMutex sync.RWMutex
	csiDataDir string // Directory for CSI-managed symlinks
}

// NewNodeServer creates a new Node server
func NewNodeServer(nodeID string) *NodeServer {
	csiDataDir := "/nix/var/nix-csi"
	// Ensure CSI data directory exists
	if err := os.MkdirAll(csiDataDir, 0755); err != nil {
		klog.Warningf("Failed to create CSI data directory %s: %v", csiDataDir, err)
	}

	return &NodeServer{
		nodeID:     nodeID,
		mounter:    mount.New(""),
		buildCache: make(map[string]string),
		csiDataDir: csiDataDir,
	}
}

// NodePublishVolume mounts the volume at the target path
func (s *NodeServer) NodePublishVolume(ctx context.Context, req *csi.NodePublishVolumeRequest) (*csi.NodePublishVolumeResponse, error) {
	volumeID := req.GetVolumeId()
	targetPath := req.GetTargetPath()
	volumeContext := req.GetVolumeContext()

	klog.Infof("NodePublishVolume: volumeID=%s targetPath=%s context=%v", volumeID, targetPath, volumeContext)

	if volumeID == "" {
		return nil, status.Error(codes.InvalidArgument, "Volume ID is required")
	}
	if targetPath == "" {
		return nil, status.Error(codes.InvalidArgument, "Target path is required")
	}

	// Determine source path - default to /nix
	sourcePath := "/nix"
	var resultStorePath string

	// Check for flake reference first (highest priority)
	if flakeRef, ok := volumeContext["flakeRef"]; ok && flakeRef != "" {
		klog.Infof("Building flake reference: %s", flakeRef)

		storePath, err := s.buildFlakeRef(ctx, flakeRef)
		if err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to build flake ref %s: %v", flakeRef, err)
		}
		resultStorePath = storePath
		klog.Infof("Flake build successful: %s -> %s", flakeRef, storePath)
	} else if storePath, ok := volumeContext["storePath"]; ok && storePath != "" {
		// Direct store path
		resultStorePath = storePath
		klog.Infof("Using specific store path: %s", storePath)
	}

	// Create volume-specific result symlink if we have a store path
	if resultStorePath != "" {
		volumeDir := filepath.Join(s.csiDataDir, volumeID)
		if err := os.MkdirAll(volumeDir, 0755); err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to create volume dir: %v", err)
		}

		resultLink := filepath.Join(volumeDir, "result")
		// Remove existing symlink if present
		os.Remove(resultLink)
		if err := os.Symlink(resultStorePath, resultLink); err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to create result symlink: %v", err)
		}
		klog.Infof("Created result symlink: %s -> %s", resultLink, resultStorePath)
	}

	// Ensure source exists
	if _, err := os.Stat(sourcePath); os.IsNotExist(err) {
		return nil, status.Errorf(codes.NotFound, "Source path %s does not exist", sourcePath)
	}

	// Create target directory
	if err := os.MkdirAll(targetPath, 0755); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to create target path: %v", err)
	}

	// Check if already mounted
	notMnt, err := s.mounter.IsLikelyNotMountPoint(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			notMnt = true
		} else {
			return nil, status.Errorf(codes.Internal, "Failed to check mount point: %v", err)
		}
	}

	if !notMnt {
		klog.Infof("Volume already mounted at %s", targetPath)
		return &csi.NodePublishVolumeResponse{}, nil
	}

	// Mount options - always mount /nix read-only
	mountOptions := []string{"bind", "ro"}

	klog.Infof("Mounting %s to %s with options %v", sourcePath, targetPath, mountOptions)

	// Perform bind mount of entire /nix
	if err := s.mounter.Mount(sourcePath, targetPath, "", mountOptions); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to mount: %v", err)
	}

	klog.Infof("Successfully mounted %s to %s", sourcePath, targetPath)
	return &csi.NodePublishVolumeResponse{}, nil
}

// buildFlakeRef builds a flake reference and returns the store path
func (s *NodeServer) buildFlakeRef(ctx context.Context, flakeRef string) (string, error) {
	// Check cache first
	s.cacheMutex.RLock()
	if storePath, ok := s.buildCache[flakeRef]; ok {
		s.cacheMutex.RUnlock()
		klog.Infof("Cache hit for %s: %s", flakeRef, storePath)
		// Verify the store path still exists
		if _, err := os.Stat(storePath); err == nil {
			return storePath, nil
		}
		// Cache entry is stale, will rebuild
		klog.Infof("Cache entry stale for %s, rebuilding", flakeRef)
	}
	s.cacheMutex.RUnlock()

	// Build the flake reference
	klog.Infof("Running: nix build %s --no-link --print-out-paths", flakeRef)

	// Create a context with timeout for the build
	buildCtx, cancel := context.WithTimeout(ctx, 10*time.Minute)
	defer cancel()

	cmd := exec.CommandContext(buildCtx, "nix", "build", flakeRef, "--no-link", "--print-out-paths")
	cmd.Env = append(os.Environ(),
		"NIX_CONFIG=experimental-features = nix-command flakes",
	)

	output, err := cmd.CombinedOutput()
	if err != nil {
		klog.Errorf("nix build failed: %v\nOutput: %s", err, string(output))
		return "", fmt.Errorf("nix build failed: %v: %s", err, string(output))
	}

	// Parse the store path from output
	storePath := strings.TrimSpace(string(output))
	// Handle multiple outputs - take the first line
	if lines := strings.Split(storePath, "\n"); len(lines) > 0 {
		storePath = strings.TrimSpace(lines[0])
	}

	if !strings.HasPrefix(storePath, "/nix/store/") {
		return "", fmt.Errorf("unexpected nix build output: %s", storePath)
	}

	// Verify the path exists
	if _, err := os.Stat(storePath); err != nil {
		return "", fmt.Errorf("built store path does not exist: %s", storePath)
	}

	// Update cache
	s.cacheMutex.Lock()
	s.buildCache[flakeRef] = storePath
	s.cacheMutex.Unlock()

	klog.Infof("Built and cached: %s -> %s", flakeRef, storePath)
	return storePath, nil
}

// NodeUnpublishVolume unmounts the volume from the target path
func (s *NodeServer) NodeUnpublishVolume(ctx context.Context, req *csi.NodeUnpublishVolumeRequest) (*csi.NodeUnpublishVolumeResponse, error) {
	volumeID := req.GetVolumeId()
	targetPath := req.GetTargetPath()

	klog.Infof("NodeUnpublishVolume: volumeID=%s targetPath=%s", volumeID, targetPath)

	if volumeID == "" {
		return nil, status.Error(codes.InvalidArgument, "Volume ID is required")
	}
	if targetPath == "" {
		return nil, status.Error(codes.InvalidArgument, "Target path is required")
	}

	// Check if mounted
	notMnt, err := s.mounter.IsLikelyNotMountPoint(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			klog.Infof("Target path %s does not exist, nothing to unmount", targetPath)
			// Still clean up volume directory
			s.cleanupVolumeDir(volumeID)
			return &csi.NodeUnpublishVolumeResponse{}, nil
		}
		return nil, status.Errorf(codes.Internal, "Failed to check mount point: %v", err)
	}

	if notMnt {
		klog.Infof("Target path %s is not a mount point", targetPath)
		// Still clean up volume directory
		s.cleanupVolumeDir(volumeID)
		return &csi.NodeUnpublishVolumeResponse{}, nil
	}

	// Unmount
	klog.Infof("Unmounting %s", targetPath)
	if err := s.mounter.Unmount(targetPath); err != nil {
		return nil, status.Errorf(codes.Internal, "Failed to unmount: %v", err)
	}

	// Remove target directory
	if err := os.RemoveAll(targetPath); err != nil {
		klog.Warningf("Failed to remove target path %s: %v", targetPath, err)
	}

	// Clean up volume-specific data
	s.cleanupVolumeDir(volumeID)

	klog.Infof("Successfully unmounted %s", targetPath)
	return &csi.NodeUnpublishVolumeResponse{}, nil
}

// cleanupVolumeDir removes the volume-specific directory and symlinks
func (s *NodeServer) cleanupVolumeDir(volumeID string) {
	volumeDir := filepath.Join(s.csiDataDir, volumeID)
	if err := os.RemoveAll(volumeDir); err != nil {
		klog.Warningf("Failed to remove volume dir %s: %v", volumeDir, err)
	} else {
		klog.Infof("Cleaned up volume dir: %s", volumeDir)
	}
}

// NodeGetCapabilities returns the capabilities of the node service
func (s *NodeServer) NodeGetCapabilities(ctx context.Context, req *csi.NodeGetCapabilitiesRequest) (*csi.NodeGetCapabilitiesResponse, error) {
	return &csi.NodeGetCapabilitiesResponse{
		Capabilities: []*csi.NodeServiceCapability{},
	}, nil
}

// NodeGetInfo returns information about the node
func (s *NodeServer) NodeGetInfo(ctx context.Context, req *csi.NodeGetInfoRequest) (*csi.NodeGetInfoResponse, error) {
	return &csi.NodeGetInfoResponse{
		NodeId: s.nodeID,
	}, nil
}

// NodeStageVolume is not implemented (not needed for ephemeral volumes)
func (s *NodeServer) NodeStageVolume(ctx context.Context, req *csi.NodeStageVolumeRequest) (*csi.NodeStageVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "NodeStageVolume not implemented")
}

// NodeUnstageVolume is not implemented (not needed for ephemeral volumes)
func (s *NodeServer) NodeUnstageVolume(ctx context.Context, req *csi.NodeUnstageVolumeRequest) (*csi.NodeUnstageVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "NodeUnstageVolume not implemented")
}

// NodeGetVolumeStats is not implemented
func (s *NodeServer) NodeGetVolumeStats(ctx context.Context, req *csi.NodeGetVolumeStatsRequest) (*csi.NodeGetVolumeStatsResponse, error) {
	return nil, status.Error(codes.Unimplemented, "NodeGetVolumeStats not implemented")
}

// NodeExpandVolume is not implemented
func (s *NodeServer) NodeExpandVolume(ctx context.Context, req *csi.NodeExpandVolumeRequest) (*csi.NodeExpandVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "NodeExpandVolume not implemented")
}

// Helper to resolve store path from various inputs
func resolveStorePath(volumeContext map[string]string) (string, error) {
	// Priority 1: Direct store path
	if storePath, ok := volumeContext["storePath"]; ok && storePath != "" {
		if !strings.HasPrefix(storePath, "/nix/store/") {
			return "", fmt.Errorf("invalid store path: must start with /nix/store/")
		}
		return storePath, nil
	}

	// Priority 2: Package name (resolve from current system)
	if pkg, ok := volumeContext["package"]; ok && pkg != "" {
		// Try to find in /run/current-system/sw/bin
		binPath := filepath.Join("/run/current-system/sw/bin", pkg)
		if target, err := os.Readlink(binPath); err == nil {
			// Get the store path from the symlink target
			// e.g., /nix/store/xxx-package/bin/pkg -> /nix/store/xxx-package
			storePath := strings.TrimSuffix(target, "/bin/"+pkg)
			if strings.HasPrefix(storePath, "/nix/store/") {
				return storePath, nil
			}
		}
	}

	// Default: mount entire /nix
	return "/nix", nil
}
