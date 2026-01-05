{ hostname, ipAddress, gateway, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
    ../../../modules/nixos/git-sync.nix
    ./services/personal-website.nix
    ./services/n8n.nix
    ./services/uptime-kuma.nix
    ./services/netdata.nix
    ./services/glitchtip.nix
    ./services/mailserver.nix
    ./services/roundcube.nix
    ./services/minio.nix
    ./services/fta-server.nix
    # BSM Test Services
    ./services/bsmart-landing.nix
    ./services/echo.nix
    ./services/ydm.nix
  ];

  services.nixos-git-sync = {
    enable = true;
    flakeTarget = "hostinger";
  };

  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.ens18.ipv4.addresses = [
      {
        address = ipAddress;
        prefixLength = 24;
      }
    ];
    defaultGateway = gateway;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
  };
}
