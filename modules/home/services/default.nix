{ username, enableLaravel, lib, ... }:
{
  home-manager.users.${username}.launchd.agents = lib.mkIf enableLaravel {
    postgresql = {
      enable = true;
      config = {
        Label = "homebrew.mxcl.postgresql@16";
        ProgramArguments = [
          "/opt/homebrew/opt/postgresql@16/bin/postgres"
          "-D"
          "/opt/homebrew/var/postgresql@16"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "/opt/homebrew";
        StandardErrorPath = "/opt/homebrew/var/log/postgresql@16.log";
        StandardOutPath = "/opt/homebrew/var/log/postgresql@16.log";
        EnvironmentVariables = {
          LC_ALL = "en_US.UTF-8";
          LANG = "en_US.UTF-8";
        };
      };
    };

    mysql = {
      enable = true;
      config = {
        Label = "homebrew.mxcl.mysql";
        ProgramArguments = [
          "/opt/homebrew/opt/mysql/bin/mysqld_safe"
          "--datadir=/opt/homebrew/var/mysql"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "/opt/homebrew";
      };
    };

    redis = {
      enable = true;
      config = {
        Label = "homebrew.mxcl.redis";
        ProgramArguments = [
          "/opt/homebrew/opt/redis/bin/redis-server"
          "/opt/homebrew/etc/redis.conf"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "/opt/homebrew";
        StandardErrorPath = "/opt/homebrew/var/log/redis.log";
        StandardOutPath = "/opt/homebrew/var/log/redis.log";
      };
    };
  };
}
