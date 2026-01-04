{ ... }:
{
  virtualisation.oci-containers.containers.uptime-kuma = {
    image = "louislam/uptime-kuma:1";
    ports = [ "3001:3001" ];
    volumes = [ "/var/lib/uptime-kuma:/app/data" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/uptime-kuma 0755 root root -"
  ];

  services.nginx.virtualHosts."uptime.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };
}
