{ config, acmeEmail, ... }:
{
  services.personal-website = {
    enable = true;
    port = 4321;
    host = "127.0.0.1";
    environmentFile = config.sops.secrets.personal_website_env.path;
    nginx.enable = false;
  };

  systemd.services.personal-website = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };
}
