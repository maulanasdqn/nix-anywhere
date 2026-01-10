{ ... }:
{
  services.rkm-admin-frontend = {
    enable = true;
  };

  services.nginx.virtualHosts."cms.rajawalikaryamulya.co.id" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3100";
      proxyWebsockets = true;
    };
  };
}
