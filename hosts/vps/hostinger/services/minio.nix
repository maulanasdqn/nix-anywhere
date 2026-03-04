{ config, pkgs, ... }:
{
  services.minio = {
    enable = true;
    listenAddress = "0.0.0.0:9000";  # Bind to all interfaces for k8s access
    consoleAddress = "0.0.0.0:9001";
    dataDir = [ "/var/lib/minio/data" ];
    rootCredentialsFile = config.sops.secrets.minio_credentials.path;
  };

  # Ensure minio service starts after sops secrets are available
  systemd.services.minio = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minio 0755 minio minio -"
    "d /var/lib/minio/data 0755 minio minio -"
  ];

  # nginx virtualHosts handled by k8s nginx-ingress now
}
