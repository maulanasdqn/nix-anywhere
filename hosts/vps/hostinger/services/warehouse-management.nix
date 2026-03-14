{ config, ... }:
{
  services.warehouse-management = {
    enable = true;
    port = 8090;
    host = "127.0.0.1";
    databaseUrl = "postgresql://warehouse:warehouse@localhost:5432/warehouse_management";
    environmentFile = config.sops.secrets.warehouse_env.path;
    nginx.enable = false;
  };

  systemd.services.wm-server = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  services.postgresql.ensureDatabases = [ "warehouse_management" ];
}
