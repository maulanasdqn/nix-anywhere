{ ... }:
{
  virtualisation.oci-containers.containers = {
    roundcube-db = {
      image = "postgres:15-alpine";
      volumes = [ "/var/lib/roundcube/postgres:/var/lib/postgresql/data" ];
      environmentFiles = [ "/etc/roundcube-db.env" ];
      extraOptions = [ "--network=roundcube-net" ];
    };

    roundcube = {
      image = "roundcube/roundcubemail:latest";
      ports = [ "9000:80" ];
      dependsOn = [ "roundcube-db" ];
      environment = {
        ROUNDCUBEMAIL_DEFAULT_HOST = "ssl://mail.msdqn.dev";
        ROUNDCUBEMAIL_DEFAULT_PORT = "993";
        ROUNDCUBEMAIL_SMTP_SERVER = "ssl://mail.msdqn.dev";
        ROUNDCUBEMAIL_SMTP_PORT = "465";
        ROUNDCUBEMAIL_PLUGINS = "archive,zipdownload,managesieve";
      };
      environmentFiles = [ "/etc/roundcube.env" ];
      extraOptions = [ "--network=roundcube-net" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/roundcube 0755 root root -"
    "d /var/lib/roundcube/postgres 0755 999 999 -"
  ];

  systemd.services.roundcube-network = {
    description = "Create Roundcube podman network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-roundcube-db.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/podman network create roundcube-net --ignore";
    };
  };

  services.nginx.virtualHosts."webmail.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
      proxyWebsockets = true;
    };
  };
}
