{ config, lib, pkgs, ... }:
let
  cfg = config.services.nixos-git-sync;
in
{
  options.services.nixos-git-sync = {
    enable = lib.mkEnableOption "NixOS config git sync";

    flakeTarget = lib.mkOption {
      type = lib.types.str;
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos-config";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nixos-config-sync = {
      description = "Sync NixOS config from git";
      path = [ pkgs.git pkgs.nixos-rebuild ];
      script = ''
        cd ${cfg.repoPath}
        git fetch origin
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse origin/main)
        if [ "$LOCAL" != "$REMOTE" ]; then
          git pull origin main
          nixos-rebuild switch --flake ${cfg.repoPath}#${cfg.flakeTarget}
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    systemd.timers.nixos-config-sync = {
      description = "Sync NixOS config periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
