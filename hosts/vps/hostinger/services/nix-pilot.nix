{ ... }:
{
  services.nix-pilot = {
    enable = true;
    port = 3001;
    address = "127.0.0.1";
    auth = {
      enable = true;
      username = "admin";
      password = "NixPilot2025Secure"; # Change this to a secure password
    };
  };

  services.nginx.virtualHosts."manage.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."api-manage.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001/api/";
      proxyWebsockets = true;
    };
  };
}
