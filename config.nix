{
  username = "ms";
  darwinHostname = "mrscraper"; # macOS hostname
  nixosHostname = "nixos"; # NixOS workstation hostname
  vpsHostname = "vps"; # VPS server hostname
  hostname = "mrscraper"; # Fallback for backwards compatibility
  enableLaravel = true;
  enableTilingWM = true; # yabai/skhd/sketchybar (darwin) or hyprland (nixos)

  # SSH public keys - REQUIRED for nixos-anywhere VPS deployment
  sshKeys = [
    # Add your SSH public key here before deploying to VPS
    # "ssh-ed25519 AAAAC3Nza... user@example.com"
  ];
}
