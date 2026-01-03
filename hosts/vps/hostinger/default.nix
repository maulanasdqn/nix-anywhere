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
      GTM_ID = "G-7TD92DV318";
      GOOGLE_ANALYTICS_ID = "G-7TD92DV318";
      SUPABASE_URL = "https://btdmfdxfqwhxnexgtxxd.supabase.co";
      SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0ZG1mZHhmcXdoeG5leGd0eHhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwMDY4MTQsImV4cCI6MjA2NjU4MjgxNH0.P0cDn1kBlF1hw8Z5Yd59LZl_CMsBnI58kzVkjDMchF4";
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

  # n8n workflow automation
  virtualisation.oci-containers.containers.n8n = {
    image = "n8nio/n8n:latest";
    ports = [ "5678:5678" ];
    volumes = [
      "/var/lib/n8n:/home/node/.n8n"
    ];
    environment = {
      N8N_HOST = "n8n.msdqn.dev";
      N8N_PORT = "5678";
      N8N_PROTOCOL = "https";
      WEBHOOK_URL = "https://n8n.msdqn.dev/";
      GENERIC_TIMEZONE = "Asia/Jakarta";
    };
  };

  # Ensure n8n data directory exists (uid 1000 = node user in container)
  systemd.tmpfiles.rules = [
    "d /var/lib/n8n 0755 1000 1000 -"
  ];

  # n8n nginx reverse proxy
  services.nginx.virtualHosts."n8n.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5678";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
        chunked_transfer_encoding off;
      '';
    };
  };
}
