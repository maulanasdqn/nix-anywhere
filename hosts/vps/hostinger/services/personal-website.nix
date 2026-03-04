{ config, acmeEmail, ... }:
{
  services.personal-website = {
    enable = true;
    port = 4321;
    host = "0.0.0.0";  # Bind to all interfaces for k8s access
    environmentFile = config.sops.secrets.personal_website_env.path;
    # nginx handled by k8s nginx-ingress
    nginx.enable = false;
  };

  # Ensure personal-website service starts after sops secrets are available
  systemd.services.personal-website = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };
}
