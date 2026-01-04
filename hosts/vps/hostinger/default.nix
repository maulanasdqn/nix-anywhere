{ hostname, ipAddress, gateway, acmeEmail, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
    ../../../modules/nixos/git-sync.nix
    ./services/n8n.nix
    ./services/uptime-kuma.nix
    ./services/netdata.nix
    ./services/glitchtip.nix
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

  services.personal-website = {
    enable = true;
    port = 4321;
    host = "127.0.0.1";
    environmentFile = "/etc/personal-website.env";
    nginx = {
      enable = true;
      domain = "msdqn.dev";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };

  services.nginx.virtualHosts."www.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "msdqn.dev";
  };
}
