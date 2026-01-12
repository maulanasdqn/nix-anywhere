{ config, pkgs, ... }:
{
  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    dataDir = [ "/var/lib/minio/data" ];
    rootCredentialsFile = "/var/lib/minio/credentials";
  };

  # Create credentials file (change password after first setup!)
  environment.etc."minio-credentials-setup".text = ''
    MINIO_ROOT_USER=minioadmin
    MINIO_ROOT_PASSWORD=MinioSecure2026!
  '';

  systemd.services.minio-credentials-setup = {
    description = "Setup MinIO credentials";
    wantedBy = [ "minio.service" ];
    before = [ "minio.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f /var/lib/minio/credentials ]; then
        mkdir -p /var/lib/minio
        cat > /var/lib/minio/credentials <<EOF
      MINIO_ROOT_USER=minioadmin
      MINIO_ROOT_PASSWORD=MinioSecure2026!
      EOF
        chmod 600 /var/lib/minio/credentials
        chown minio:minio /var/lib/minio/credentials
      fi
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minio 0755 minio minio -"
    "d /var/lib/minio/data 0755 minio minio -"
  ];

  services.nginx.virtualHosts = {
    # Minio Console
    "minio.msdqn.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9001";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-NginX-Proxy true;

          proxy_connect_timeout 300;
          proxy_read_timeout 300;
          proxy_send_timeout 300;

          chunked_transfer_encoding off;
        '';
      };
    };

    # S3 API endpoint
    "s3.msdqn.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9000";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-NginX-Proxy true;

          proxy_connect_timeout 300;
          proxy_http_version 1.1;

          # Required for large file uploads
          client_max_body_size 100M;
          proxy_buffering off;
          proxy_request_buffering off;
          chunked_transfer_encoding off;
        '';
      };
    };
  };
}
