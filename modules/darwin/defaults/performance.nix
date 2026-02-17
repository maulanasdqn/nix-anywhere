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
            # Disable all sleep modes
            pmset -a hibernatemode 0
            pmset -a sleep 0
            pmset -a disksleep 0
            pmset -a displaysleep 0
            pmset -a powernap 0
            pmset -a autopoweroff 0
            pmset -a standby 0
            pmset -a standbydelayhigh 0
            pmset -a standbydelaylow 0
            pmset -a proximitywake 0
            pmset -a ttyskeepawake 1

            # Force high performance
            pmset -a lowpowermode 0
            pmset -a gpuswitch 0
            pmset -a sms 0

            # Disable Siri
            defaults write com.apple.assistant.support "Assistant Enabled" -bool false
            launchctl disable "user/$UID/com.apple.Siri" 2>/dev/null || true
            launchctl disable "gui/$UID/com.apple.Siri" 2>/dev/null || true

            # Remove sleep image
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
      kern.maxfiles=524288
      kern.maxfilesperproc=262144
      kern.maxproc=2048
      kern.maxprocperuid=1024
      kern.ipc.somaxconn=2048
      kern.ipc.nmbclusters=65536
      net.inet.tcp.sendspace=262144
      net.inet.tcp.recvspace=262144
      net.inet.udp.recvspace=262144
      net.inet.udp.maxdgram=65535
    '';
  };

  environment.systemPackages = with pkgs; [
    bottom
  ];
}
