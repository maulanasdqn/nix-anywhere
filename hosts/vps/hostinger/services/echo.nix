{ pkgs, ... }:
{
  services.echo-frontend = {
    enable = true;
    domain = "test-echo.msdqn.dev";
  };

  services.echo-backend = {
    enable = true;
    domain = "test-api-echo.msdqn.dev";
    port = 3100;
    environmentFile = "/etc/echo-backend.env";
  };

  services.bundle-social-service = {
    enable = true;
    port = 3101;
    environmentFile = "/etc/bundle-social-service.env";
  };

  virtualisation.oci-containers.containers = {
    echo-postgres = {
      image = "postgres:16-alpine";
      volumes = [ "/var/lib/echo/postgres:/var/lib/postgresql/data" ];
      environmentFiles = [ "/etc/echo-postgres.env" ];
      extraOptions = [ "--network=echo-test-net" ];
    };

    echo-redis = {
      image = "redis:7-alpine";
      volumes = [ "/var/lib/echo/redis:/data" ];
      cmd = [
        "redis-server"
        "--appendonly"
        "yes"
      ];
      extraOptions = [ "--network=echo-test-net" ];
    };

    echo-minio = {
      image = "minio/minio:latest";
      ports = [
        "9010:9000"
        "9011:9001"
      ];
      volumes = [ "/var/lib/echo/minio:/data" ];
      environmentFiles = [ "/etc/echo-minio.env" ];
      cmd = [
        "server"
        "/data"
        "--console-address"
        ":9001"
      ];
      extraOptions = [ "--network=echo-test-net" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/echo 0755 root root -"
    "d /var/lib/echo/postgres 0755 999 999 -"
    "d /var/lib/echo/redis 0755 999 999 -"
    "d /var/lib/echo/minio 0755 root root -"
  ];

  systemd.services.echo-test-network = {
    description = "Create Echo test podman network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "podman-echo-postgres.service"
      "podman-echo-redis.service"
      "podman-echo-minio.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create echo-test-net --ignore";
    };
  };

  services.nginx.virtualHosts."test-s3-echo.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9010";
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 300;
        proxy_http_version 1.1;
        client_max_body_size 0;
        proxy_buffering off;
        proxy_request_buffering off;
        chunked_transfer_encoding off;
      '';
    };
  };
}
