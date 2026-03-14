{ config, pkgs, ... }:
{
  services.warehouse-management = {
    enable = true;
    port = 8090;
    host = "127.0.0.1";
    databaseUrl = "postgresql://warehouse_management:warehouse_management@localhost:5432/warehouse_management";
    environmentFile = config.sops.secrets.warehouse_env.path;
    nginx.enable = false;
  };

  systemd.services.postgresql.postStart = pkgs.lib.mkAfter ''
    $PSQL -c "ALTER USER warehouse_management WITH PASSWORD 'warehouse_management';" || true
  '';

  systemd.services.wm-server = {
    after = [ "sops-nix.service" "postgresql.service" ];
    wants = [ "sops-nix.service" ];
    requires = [ "postgresql.service" ];
  };
}
