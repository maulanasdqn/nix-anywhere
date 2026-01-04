{ pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    glitchtip-postgres = {
      image = "postgres:15-alpine";
      volumes = [ "/var/lib/glitchtip/postgres:/var/lib/postgresql/data" ];
      environmentFiles = [ "/etc/glitchtip-postgres.env" ];
      extraOptions = [ "--network=glitchtip-net" ];
    };

    glitchtip-redis = {
      image = "redis:7-alpine";
      extraOptions = [ "--network=glitchtip-net" ];
    };

    glitchtip-web = {
      image = "glitchtip/glitchtip:latest";
      ports = [ "8000:8000" ];
      dependsOn = [ "glitchtip-postgres" "glitchtip-redis" ];
      environmentFiles = [ "/etc/glitchtip.env" ];
      extraOptions = [ "--network=glitchtip-net" ];
    };

    glitchtip-worker = {
      image = "glitchtip/glitchtip:latest";
      dependsOn = [ "glitchtip-postgres" "glitchtip-redis" ];
      cmd = [ "./bin/run-celery-with-beat.sh" ];
      environmentFiles = [ "/etc/glitchtip.env" ];
      extraOptions = [ "--network=glitchtip-net" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/glitchtip 0755 root root -"
    "d /var/lib/glitchtip/postgres 0755 999 999 -"
  ];

  systemd.services.glitchtip-network = {
    description = "Create Glitchtip podman network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-glitchtip-postgres.service" "podman-glitchtip-redis.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create glitchtip-net --ignore";
    };
  };

  services.nginx.virtualHosts."glitchtip.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8000";
      proxyWebsockets = true;
    };
  };
}
