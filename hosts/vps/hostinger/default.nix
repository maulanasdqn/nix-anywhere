# Hostinger VPS configuration
# Deploy: nix run github:nix-community/nixos-anywhere -- --flake .#hostinger --build-on remote root@<IP>
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
  ];

  networking = {
    hostName = "msdqn";

    # Hostinger requires static IP (no DHCP)
    useDHCP = false;
    interfaces.ens18.ipv4.addresses = [{
      address = "72.62.125.38";
      prefixLength = 24;
    }];
    defaultGateway = "72.62.125.254";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
  };
}
