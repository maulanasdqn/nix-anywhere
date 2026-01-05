{ pkgs, ... }:
{
  services.ydm-frontend = {
    enable = true;
    domain = "test-ydm.msdqn.dev";
  };

  services.ydm-backend = {
    enable = true;
    domain = "test-api-ydm.msdqn.dev";
    port = 3200;  # Changed from 3001 to avoid conflict with uptime-kuma
    environmentFile = "/etc/ydm-backend.env";
    enableGrpcServices = true;
  };

  virtualisation.oci-containers.containers = {
    ydm-postgres = {
      image = "postgres:15-alpine";
      volumes = [ "/var/lib/ydm/postgres:/var/lib/postgresql/data" ];
      environmentFiles = [ "/etc/ydm-postgres.env" ];
      extraOptions = [ "--network=ydm-test-net" ];
    };

    ydm-redis = {
      image = "redis:7-alpine";
      volumes = [ "/var/lib/ydm/redis:/data" ];
      cmd = [
        "redis-server"
        "--appendonly"
        "yes"
      ];
      extraOptions = [ "--network=ydm-test-net" ];
    };

    ydm-minio = {
      image = "minio/minio:latest";
      ports = [
        "9020:9000"
        "9021:9001"
      ];
      volumes = [ "/var/lib/ydm/minio:/data" ];
      environmentFiles = [ "/etc/ydm-minio.env" ];
      cmd = [
        "server"
        "/data"
        "--console-address"
        ":9001"
      ];
      extraOptions = [ "--network=ydm-test-net" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/ydm 0755 root root -"
    "d /var/lib/ydm/postgres 0755 999 999 -"
    "d /var/lib/ydm/redis 0755 999 999 -"
    "d /var/lib/ydm/minio 0755 root root -"
  ];

  systemd.services.ydm-test-network = {
    description = "Create YDM test podman network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "podman-ydm-postgres.service"
      "podman-ydm-redis.service"
      "podman-ydm-minio.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create ydm-test-net --ignore";
    };
  };

  services.nginx.virtualHosts."test-s3-ydm.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9020";
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
