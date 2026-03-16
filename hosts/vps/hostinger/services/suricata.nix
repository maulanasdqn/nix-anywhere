{ pkgs, ... }:
let
  suricataConfig = pkgs.writeText "suricata.yaml" ''
    %YAML 1.1
    ---

    vars:
      address-groups:
        HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
        EXTERNAL_NET: "!$HOME_NET"
        HTTP_SERVERS: "$HOME_NET"
        SMTP_SERVERS: "$HOME_NET"
        SQL_SERVERS: "$HOME_NET"
        DNS_SERVERS: "$HOME_NET"
        TELNET_SERVERS: "$HOME_NET"
        AIM_SERVERS: "$EXTERNAL_NET"
        DC_SERVERS: "$HOME_NET"
        DNP3_SERVER: "$HOME_NET"
        DNP3_CLIENT: "$HOME_NET"
        MODBUS_CLIENT: "$HOME_NET"
        MODBUS_SERVER: "$HOME_NET"
        ENIP_CLIENT: "$HOME_NET"
        ENIP_SERVER: "$HOME_NET"
      port-groups:
        HTTP_PORTS: "80"
        SHELLCODE_PORTS: "!80"
        ORACLE_PORTS: 1521
        SSH_PORTS: 22
        DNP3_PORTS: 20000
        MODBUS_PORTS: 502
        FILE_DATA_PORTS: "[$HTTP_PORTS,110,143]"
        FTP_PORTS: 21
        GENEVE_PORTS: 6081
        VXLAN_PORTS: 4789
        TEREDO_PORTS: 3544

    default-log-dir: /var/log/suricata/

    outputs:
      - eve-log:
          enabled: yes
          filetype: regular
          filename: eve.json
          community-id: true
          types:
            - alert:
                tagged-packets: yes
            - anomaly:
                enabled: yes
                types:
                  decode: yes
                  stream: yes
                  applayer: yes
            - http:
                extended: yes
            - dns
            - tls:
                extended: yes
            - files:
                force-magic: no
            - smtp
            - ssh
            - stats:
                totals: yes
                threads: no
                deltas: no
            - flow
      - stats:
          enabled: yes
          filename: stats.log
          append: yes
          totals: yes
          threads: no

    af-packet:
      - interface: ens18
        cluster-id: 99
        cluster-type: cluster_flow
        defrag: yes
        use-mmap: yes
        tpacket-v3: yes

    app-layer:
      protocols:
        http:
          enabled: yes
        tls:
          enabled: yes
          detection-ports:
            dp: 443
        ssh:
          enabled: yes
        dns:
          enabled: yes
          tcp:
            enabled: yes
          udp:
            enabled: yes
        smtp:
          enabled: yes
        ftp:
          enabled: yes

    detect:
      profile: medium
      sgh-mpm-context: auto

    host-os-policy:
      linux: [0.0.0.0/0]

    logging:
      default-log-level: notice
      outputs:
        - console:
            enabled: yes
        - file:
            enabled: yes
            level: info
            filename: suricata.log

    default-rule-path: /var/lib/suricata/rules

    rule-files:
      - suricata.rules

    coredump:
      max-dump: unlimited
  '';
in
{
  # Suricata IDS
  systemd.services.suricata = {
    description = "Suricata IDS";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      mkdir -p /var/log/suricata
      mkdir -p /var/lib/suricata/rules
      mkdir -p /var/run/suricata
      cp -f ${suricataConfig} /etc/suricata/suricata.yaml

      # Download/update rules if older than 24h or missing
      if [ ! -f /var/lib/suricata/rules/suricata.rules ] || \
         [ $(find /var/lib/suricata/rules/suricata.rules -mmin +1440 2>/dev/null | wc -l) -gt 0 ]; then
        ${pkgs.suricata}/bin/suricata-update \
          --suricata ${pkgs.suricata}/bin/suricata \
          --suricata-conf /etc/suricata/suricata.yaml \
          --data-dir /var/lib/suricata \
          --output /var/lib/suricata/rules \
          2>/dev/null || true
      fi
    '';

    serviceConfig = {
      ExecStart = "${pkgs.suricata}/bin/suricata -c /etc/suricata/suricata.yaml --af-packet -D";
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 1";
      Type = "forking";
      PIDFile = "/var/run/suricata/suricata.pid";
      Restart = "on-failure";
      RestartSec = "10s";
      # Suricata needs root for raw packet capture
      CapabilityBoundingSet = "CAP_NET_RAW CAP_NET_ADMIN CAP_SYS_NICE";
      AmbientCapabilities = "CAP_NET_RAW CAP_NET_ADMIN CAP_SYS_NICE";
    };
  };

  # Weekly rule update timer
  systemd.services.suricata-update = {
    description = "Update Suricata rules";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.suricata}/bin/suricata-update --suricata ${pkgs.suricata}/bin/suricata --suricata-conf /etc/suricata/suricata.yaml --data-dir /var/lib/suricata --output /var/lib/suricata/rules";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl kill -s USR2 suricata.service";
    };
  };

  systemd.timers.suricata-update = {
    description = "Weekly Suricata rule update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # Ensure config directory exists
  systemd.tmpfiles.rules = [
    "d /etc/suricata 0755 root root -"
    "d /var/log/suricata 0755 root root -"
    "d /var/lib/suricata/rules 0755 root root -"
  ];
}
