{ pkgs, ... }:
{
  virtualisation.oci-containers.containers.mailserver = {
    image = "ghcr.io/docker-mailserver/docker-mailserver:latest";
    hostname = "mail.msdqn.dev";
    ports = [
      "25:25"
      "465:465"
      "587:587"
      "143:143"
      "993:993"
    ];
    volumes = [
      "/var/lib/mailserver/mail-data:/var/mail"
      "/var/lib/mailserver/mail-state:/var/mail-state"
      "/var/lib/mailserver/mail-logs:/var/log/mail"
      "/var/lib/mailserver/config:/tmp/docker-mailserver"
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/acme/mail.msdqn.dev:/etc/letsencrypt/live/mail.msdqn.dev:ro"
    ];
    environmentFiles = [ "/etc/mailserver.env" ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_PTRACE"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mailserver 0755 root root -"
    "d /var/lib/mailserver/mail-data 0755 root root -"
    "d /var/lib/mailserver/mail-state 0755 root root -"
    "d /var/lib/mailserver/mail-logs 0755 root root -"
    "d /var/lib/mailserver/config 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ 25 465 587 143 993 ];

  security.acme.certs."mail.msdqn.dev" = {
    domain = "mail.msdqn.dev";
    group = "acme";
    reloadServices = [ "podman-mailserver.service" ];
  };

  services.nginx.virtualHosts."mail.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "200 'Mail server running'";
      extraConfig = ''
        default_type text/plain;
      '';
    };
  };
}
