{
  username = "ms";
  darwinHostname = "mrscraper"; # macOS hostname
  nixosHostname = "nixos"; # NixOS workstation hostname
  hostname = "mrscraper"; # Fallback for backwards compatibility
  enableLaravel = true;
  enableTilingWM = true; # yabai/skhd/sketchybar (darwin) or hyprland (nixos)

  # SSH public keys - REQUIRED for nixos-anywhere VPS deployment
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer"
  ];
}
