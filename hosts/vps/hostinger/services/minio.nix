{ config, pkgs, ... }:
{
  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    dataDir = [ "/var/lib/minio/data" ];
    rootCredentialsFile = config.sops.secrets.minio_credentials.path;
  };

  systemd.services.minio = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minio 0755 minio minio -"
    "d /var/lib/minio/data 0755 minio minio -"
  ];
}
