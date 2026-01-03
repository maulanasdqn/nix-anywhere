# Git-based NixOS config sync
# Clone: git clone https://github.com/maulanasdqn/nix-anywhere.git /etc/nixos-config
# Manual rebuild: nixos-rebuild switch --flake /etc/nixos-config#<target>
{ config, lib, pkgs, ... }:
let
  cfg = config.services.nixos-git-sync;
in
{
  options.services.nixos-git-sync = {
    enable = lib.mkEnableOption "NixOS config git sync";

    flakeTarget = lib.mkOption {
      type = lib.types.str;
      description = "Flake target to build (e.g., hostinger, digitalocean)";
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos-config";
      description = "Path to the cloned config repository";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Sync interval (systemd calendar format)";
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
