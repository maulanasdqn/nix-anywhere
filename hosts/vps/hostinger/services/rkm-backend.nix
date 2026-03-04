{ config, acmeEmail, ... }:
{
  services.rkm-backend = {
    enable = true;
    port = 3300;
    host = "0.0.0.0";  # Bind to all interfaces for k8s access
    databaseUrl = "postgresql://rkm:rkm@localhost:5432/rkm";
    environmentFile = config.sops.secrets.rkm_backend_env.path;
    # nginx handled by k8s nginx-ingress
    nginx.enable = false;
  };

  # Ensure rkm-backend service starts after sops secrets are available and MinIO
  systemd.services.rkm-backend = {
    after = [ "sops-nix.service" "minio.service" ];
    wants = [ "sops-nix.service" "minio.service" ];
    serviceConfig.EnvironmentFile = [
      config.sops.secrets.minio_env.path
    ];
    environment = {
      MINIO_ENDPOINT = "http://127.0.0.1:9000";
      MINIO_BUCKET = "rkm-media";
      MINIO_REGION = "us-east-1";
      MINIO_PUBLIC_URL = "https://s3.msdqn.dev/rkm-media";
    };
  };
}
