{ config, acmeEmail, ... }:
{
  services.roasting-startup = {
    enable = true;
    port = 7676;
    host = "127.0.0.1";
    domain = "roast.kilat.app";
    nginx.enable = false;
    environmentFile = config.sops.secrets.roasting_startup_env.path;
  };

  systemd.services.roasting-startup = {
    after = [ "sops-nix.service" "postgresql.service" ];
    wants = [ "sops-nix.service" ];
  };
}
