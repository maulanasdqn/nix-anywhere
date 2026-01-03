# DigitalOcean Droplet configuration
# Deploy: nix run github:nix-community/nixos-anywhere -- --flake .#digitalocean --build-on remote root@<IP>
{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
  ];

  networking = {
    hostName = "droplet"; # Change per droplet
    useDHCP = true;       # DigitalOcean provides DHCP
  };
}
