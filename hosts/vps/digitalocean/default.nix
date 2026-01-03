{ hostname, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
    ../../../modules/nixos/git-sync.nix
  ];

  services.nixos-git-sync = {
    enable = true;
    flakeTarget = "digitalocean";
  };

  networking = {
    hostName = hostname;
    useDHCP = true;
  };
}
