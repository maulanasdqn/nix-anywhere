{ ... }:
{
  virtualisation.oci-containers.containers.minio = {
    image = "minio/minio:latest";
    ports = [
      "9002:9000"  # S3 API
      "9003:9001"  # Console
    ];
    volumes = [ "/var/lib/minio/data:/data" ];
    environmentFiles = [ "/etc/minio.env" ];
    cmd = [ "server" "/data" "--console-address" ":9001" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minio 0755 root root -"
    "d /var/lib/minio/data 0755 root root -"
  ];

  services.nginx.virtualHosts = {
    # Minio Console
    "minio.msdqn.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9003";
        proxyWebsockets = true;
      };
    };

    # S3 API endpoint
    "s3.msdqn.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9002";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # Required for large file uploads
          client_max_body_size 0;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };
}
