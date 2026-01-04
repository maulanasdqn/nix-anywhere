{ acmeEmail, pkgs, ... }:
{
  services.fta-server = {
    enable = true;
    port = 3000;
    host = "127.0.0.1";
    environmentFile = "/etc/fta-server.env";
    nginx = {
      enable = true;
      domain = "api-fta.msdqn.dev";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };

  # PostgreSQL for fta-server
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "fta" ];
    ensureUsers = [
      {
        name = "fta";
        ensureDBOwnership = true;
      }
    ];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
    '';
  };

  # Redis for fta-server (sessions/caching)
  services.redis.servers.fta = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };
}
