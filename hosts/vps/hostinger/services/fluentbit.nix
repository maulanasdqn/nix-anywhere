{ pkgs, ... }:
let
  fluentbitConfig = pkgs.writeText "fluent-bit.conf" ''
    [SERVICE]
        flush        5
        daemon       off
        log_level    info
        parsers_file ${pkgs.fluent-bit}/etc/fluent-bit/parsers.conf

    [INPUT]
        name             tail
        path             /var/log/syslog,/var/log/messages
        tag              syslog
        read_from_head   true
        skip_empty_lines on

    [INPUT]
        name             tail
        path             /var/log/auth.log,/var/log/secure
        tag              auth
        read_from_head   true
        skip_empty_lines on

    [INPUT]
        name             tail
        path             /var/log/kern.log
        tag              kernel
        read_from_head   true
        skip_empty_lines on

    [INPUT]
        name             systemd
        tag              systemd.*
        read_from_tail   on

    [OUTPUT]
        name             http
        match            *
        host             ingest-aysiem.msdqn.dev
        port             443
        uri              /api/v1/ingest/agent
        format           json_lines
        json_date_key    timestamp
        json_date_format iso8601
        tls              on
        header           X-Node-Id 019ceabb-b183-79b2-8622-2bb6652af6dc
        header           X-Node-Hostname msdqn
  '';
in
{
  systemd.services.fluent-bit = {
    description = "Fluent Bit - AYSIEM Agent";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit -c ${fluentbitConfig}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
