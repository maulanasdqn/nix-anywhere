# Local Configuration Override (git-ignored)
# Copy this file to config.local.nix to override defaults
#
# cp config.example.nix config.local.nix
#
# This file is merged with config.nix, so you only need to
# specify the values you want to override.
{
  # Darwin (macOS)
  # darwinUsername = "your-username";
  # darwinHostname = "your-mac-hostname";
  # darwinEnableTilingWM = true;  # yabai, skhd, sketchybar

  # Workstation (NixOS desktop)
  # workstationUsername = "your-username";
  # workstationHostname = "your-workstation-hostname";
  # workstationEnableTilingWM = true;  # hyprland, waybar, wofi

  # VPS - Hostinger
  # vpsHostingerUsername = "your-username";
  # vpsHostingerHostname = "your-vps-hostname";
  # vpsHostingerIP = "your-vps-ip";
  # vpsHostingerGateway = "your-gateway-ip";

  # VPS - DigitalOcean
  # vpsDigitalOceanUsername = "your-username";
  # vpsDigitalOceanHostname = "your-droplet-hostname";

  # Development tools
  # enableLaravel = true;  # PHP, Composer, MySQL, PostgreSQL, Redis
  # enableRust = true;     # Rust toolchain
  # enableVolta = true;    # Node.js version manager

  # SSH public keys for authorized_keys
  # sshKeys = [
  #   "ssh-ed25519 AAAAC3Nza... user@example.com"
  # ];
}
