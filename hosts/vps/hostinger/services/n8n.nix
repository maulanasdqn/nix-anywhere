{ ... }:
{
  virtualisation.oci-containers.containers.n8n = {
    image = "n8nio/n8n:latest";
    ports = [ "5678:5678" ];
    volumes = [ "/var/lib/n8n:/home/node/.n8n" ];
    environmentFiles = [ "/etc/n8n.env" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/n8n 0755 1000 1000 -"
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
}
