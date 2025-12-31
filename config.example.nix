# Local Configuration Override (git-ignored)
# Copy this file to config.local.nix to override defaults
#
# cp config.example.nix config.local.nix
#
# This file is merged with config.nix, so you only need to
# specify the values you want to override.
#
# This configuration supports both NixOS and nix-darwin (macOS).
{
  # Your username (used for both NixOS and Darwin)
  # username = "your-username";

  # Hostnames for each system
  # darwinHostname = "your-mac-hostname";  # macOS hostname
  # nixosHostname = "your-nixos-hostname"; # NixOS hostname

  # Enable/disable Laravel development environment (darwin only)
  # When true: installs PHP, Composer, MySQL, PostgreSQL, Redis
  # When false: skips Laravel-related packages and aliases
  # enableLaravel = true;

  # Enable/disable tiling window manager (darwin only)
  # When true: installs yabai, skhd, sketchybar
  # When false: uses default macOS window management
  # enableTilingWM = true;

  # SSH public keys for authorized_keys
  # Add your public keys here for SSH access
  # sshKeys = [
  #   "ssh-ed25519 AAAAC3Nza... user@example.com"
  #   "ssh-rsa AAAAB3Nza... another@example.com"
  # ];
}
