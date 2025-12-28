{ pkgs, ... }:
{
  # MAXIMUM PERFORMANCE MODE - No battery consideration
  launchd.daemons = {
    # Performance tweaks daemon
    performance-mode = {
      serviceConfig = {
        Label = "com.local.performance-mode";
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # ===== POWER: MAXIMUM PERFORMANCE =====
            # Disable hibernation completely
            pmset -a hibernatemode 0

            # Never sleep
            pmset -a sleep 0
            pmset -a disksleep 0
            pmset -a displaysleep 0

            # Disable power nap
            pmset -a powernap 0

            # Disable auto power off
            pmset -a autopoweroff 0

            # Disable standby
            pmset -a standby 0

            # High performance mode (fans can spin up)
            pmset -a lowpowermode 0

            # Disable GPU switching - always use high performance
            pmset -a gpuswitch 0

            # Disable sudden motion sensor
            pmset -a sms 0

            # ===== DISABLE TELEMETRY/ANALYTICS =====
            defaults write com.apple.assistant.support "Assistant Enabled" -bool false

            # ===== MEMORY PRESSURE =====
            # Disable memory compression warnings
            # (M2 handles memory pressure well)

            # ===== REMOVE SLEEP IMAGE (save SSD space) =====
            rm -f /var/vm/sleepimage 2>/dev/null || true
            mkdir -p /var/vm
            touch /var/vm/sleepimage
            chflags uchg /var/vm/sleepimage

            echo "Performance mode activated"
          ''
        ];
        RunAtLoad = true;
      };
    };

    # Disable Time Machine local snapshots
    disable-tm-local = {
      serviceConfig = {
        Label = "com.local.disable-tm-local";
        ProgramArguments = [
          "/usr/bin/tmutil"
          "disablelocal"
        ];
        RunAtLoad = true;
      };
    };
  };

  # System-level performance tweaks
  environment.etc = {
    # Increase file descriptor limits for heavy dev work
    "sysctl.conf".text = ''
      kern.maxfiles=524288
      kern.maxfilesperproc=262144
      kern.maxproc=2048
      kern.maxprocperuid=1024
    '';
  };

  # Install performance monitoring tools
  environment.systemPackages = with pkgs; [
    bottom # Better htop alternative (btm command)
  ];
}
