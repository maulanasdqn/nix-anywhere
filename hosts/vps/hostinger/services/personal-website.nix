{ acmeEmail, ... }:
{
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
