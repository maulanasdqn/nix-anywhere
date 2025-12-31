{
  username = "ms";
  darwinHostname = "mrscraper"; # macOS hostname
  nixosHostname = "nixos"; # NixOS hostname
  hostname = "mrscraper"; # Fallback for backwards compatibility
  enableLaravel = true;
  enableTilingWM = true; # yabai, skhd, sketchybar (darwin only)
  sshKeys = [
    # "ssh-ed25519 AAAAC3Nza... user@example.com"
    # "ssh-rsa AAAAB3Nza... another@example.com"
  ];
}
