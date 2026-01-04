{ hostname, ipAddress, gateway, acmeEmail, ... }:
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

  virtualisation.oci-containers.containers = {
    n8n = {
      image = "n8nio/n8n:latest";
      ports = [ "5678:5678" ];
      volumes = [ "/var/lib/n8n:/home/node/.n8n" ];
      environment = {
        N8N_HOST = "n8n.msdqn.dev";
        N8N_PORT = "5678";
        N8N_PROTOCOL = "https";
        WEBHOOK_URL = "https://n8n.msdqn.dev/";
        GENERIC_TIMEZONE = "Asia/Jakarta";
      };
    };

    uptime-kuma = {
      image = "louislam/uptime-kuma:1";
      ports = [ "3001:3001" ];
      volumes = [ "/var/lib/uptime-kuma:/app/data" ];
    };

    netdata = {
      image = "netdata/netdata:stable";
      ports = [ "19999:19999" ];
      volumes = [
        "netdataconfig:/etc/netdata"
        "netdatalib:/var/lib/netdata"
        "netdatacache:/var/cache/netdata"
        "/:/host/root:ro,rslave"
        "/etc/passwd:/host/etc/passwd:ro"
        "/etc/group:/host/etc/group:ro"
        "/etc/localtime:/etc/localtime:ro"
        "/proc:/host/proc:ro"
        "/sys:/host/sys:ro"
        "/etc/os-release:/host/etc/os-release:ro"
        "/var/log:/host/var/log:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      environment = {
        DO_NOT_TRACK = "1";
        NETDATA_DISABLE_CLOUD = "1";
      };
      extraOptions = [
        "--cap-add=SYS_PTRACE"
        "--cap-add=SYS_ADMIN"
        "--security-opt=apparmor=unconfined"
        "--pid=host"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/n8n 0755 1000 1000 -"
    "d /var/lib/uptime-kuma 0755 root root -"
  ];

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

  services.nginx.virtualHosts."uptime.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."netdata.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19999";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."www.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "msdqn.dev";
  };
}
