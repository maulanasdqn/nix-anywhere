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

  # Ensure rkm-backend service starts after sops secrets are available and MinIO
  systemd.services.rkm-backend = {
    after = [ "sops-nix.service" "minio.service" ];
    wants = [ "sops-nix.service" "minio.service" ];
    environment = {
      MINIO_ENDPOINT = "http://127.0.0.1:9000";
      MINIO_ACCESS_KEY = "minioadmin";
      MINIO_SECRET_KEY = "MinioSecure2026!";
      MINIO_BUCKET = "rkm-media";
      MINIO_REGION = "us-east-1";
      MINIO_PUBLIC_URL = "https://s3.msdqn.dev";
    };
  };
}
