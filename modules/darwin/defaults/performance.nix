{ pkgs, ... }:
{
  launchd.daemons = {
    performance-mode = {
      serviceConfig = {
        Label = "com.local.performance-mode";
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Disable auto-sleep from idle (but lid close still sleeps)
            pmset -a hibernatemode 0
            pmset -a disksleep 0
            pmset -a displaysleep 0
            pmset -a powernap 0
            pmset -a autopoweroff 0
            pmset -a standby 0
            pmset -a proximitywake 0
            pmset -a ttyskeepawake 1

            # Force max CPU performance
            pmset -a lowpowermode 0
            pmset -a gpuswitch 2
            pmset -a sms 0
            pmset -a lidwake 1
            pmset -a lessbright 0
            pmset -a halfdim 0

            # Disable CPU throttling (keep fans spinning)
            pmset -a highstandbythreshold 100

            # Disable Siri
            defaults write com.apple.assistant.support "Assistant Enabled" -bool false
            launchctl disable "user/$UID/com.apple.Siri" 2>/dev/null || true
            launchctl disable "gui/$UID/com.apple.Siri" 2>/dev/null || true

            # Apply sysctl settings
            sysctl -w kern.maxfiles=524288 2>/dev/null || true
            sysctl -w kern.maxfilesperproc=262144 2>/dev/null || true
            sysctl -w kern.maxproc=4096 2>/dev/null || true
            sysctl -w kern.maxprocperuid=2048 2>/dev/null || true
            sysctl -w kern.ipc.somaxconn=4096 2>/dev/null || true

            echo "Performance mode activated"
          ''
        ];
        RunAtLoad = true;
      };
    };

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

    disable-spotlight-indexing = {
      serviceConfig = {
        Label = "com.local.disable-spotlight";
        ProgramArguments = [
          "/usr/bin/mdutil"
          "-a"
          "-i"
          "off"
        ];
        RunAtLoad = true;
      };
    };
  };

  environment.etc = {
    "sysctl.conf".text = ''
      # File descriptors
      kern.maxfiles=524288
      kern.maxfilesperproc=262144
      kern.maxproc=4096
      kern.maxprocperuid=2048

      # Network buffers
      kern.ipc.somaxconn=4096
      kern.ipc.nmbclusters=131072
      net.inet.tcp.sendspace=524288
      net.inet.tcp.recvspace=524288
      net.inet.udp.recvspace=524288
      net.inet.udp.maxdgram=65535
      net.inet.tcp.mssdflt=1460
      net.inet.tcp.win_scale_factor=8

    '';
  };

  environment.systemPackages = with pkgs; [
    bottom
  ];
}
