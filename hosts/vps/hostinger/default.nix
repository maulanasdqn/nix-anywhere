{ hostname, ipAddress, gateway, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
    ../../../modules/nixos/git-sync.nix
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

  # Personal website (Astro SSR)
  systemd.services.personal-website = {
    description = "Personal Website (Astro)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      NODE_ENV = "production";
      HOST = "127.0.0.1";
      PORT = "4321";
    };
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/var/www/personal-website";
      ExecStart = "${pkgs.nodejs_22}/bin/node ./dist/server/entry.mjs";
      Restart = "always";
      RestartSec = "10";
      User = "root";
    };
  };

  # Nginx reverse proxy with SSL
  services.nginx.virtualHosts."msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4321";
      proxyWebsockets = true;
    };
  };
}
