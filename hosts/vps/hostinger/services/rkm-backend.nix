{ config, acmeEmail, ... }:
{
  services.rkm-backend = {
    enable = true;
    port = 3300;
    host = "127.0.0.1";
    databaseUrl = "postgresql://rkm:rkm@localhost:5432/rkm";
    environmentFile = config.sops.secrets.rkm_backend_env.path;
    nginx = {
      enable = true;
      domain = "api.rajawalikaryamulya.co.id";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };

  # Ensure rkm-backend service starts after sops secrets are available
  systemd.services.rkm-backend = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };
}
