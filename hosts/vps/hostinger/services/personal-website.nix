{ config, acmeEmail, ... }:
{
  services.personal-website = {
    enable = true;
    port = 4321;
    host = "127.0.0.1";
    environmentFile = config.sops.secrets.personal_website_env.path;
    nginx = {
      enable = true;
      domain = "msdqn.dev";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };

  # Ensure personal-website service starts after sops secrets are available
  systemd.services.personal-website = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  services.nginx.virtualHosts."www.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "msdqn.dev";
  };
}
