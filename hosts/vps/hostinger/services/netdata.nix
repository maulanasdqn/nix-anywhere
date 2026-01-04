{ ... }:
{
  virtualisation.oci-containers.containers.netdata = {
    image = "netdata/netdata:v1.40.1";
    ports = [ "19999:19999" ];
    volumes = [
      "/var/lib/netdata-config/netdata.conf:/etc/netdata/netdata.conf:ro"
      "netdatalib:/var/lib/netdata"
      "netdatacache:/var/cache/netdata"
      "/:/host/root:ro,rslave"
      "/etc/passwd:/host/etc/passwd:ro"
      "/etc/group:/host/etc/group:ro"
      "/etc/localtime:/etc/localtime:ro"
      "/proc:/host/proc:ro"
      "/sys:/host/sys:ro"
      "/etc/os-release:/host/etc/os-release:ro"
      "/var/log:/host/var/log:ro"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    environment = {
      DO_NOT_TRACK = "1";
      NETDATA_DISABLE_CLOUD = "1";
    };
    extraOptions = [
      "--cap-add=SYS_PTRACE"
      "--cap-add=SYS_ADMIN"
      "--security-opt=apparmor=unconfined"
      "--pid=host"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/netdata-config 0755 root root -"
  ];

  services.nginx.virtualHosts."netdata.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19999";
      proxyWebsockets = true;
    };
  };
}
