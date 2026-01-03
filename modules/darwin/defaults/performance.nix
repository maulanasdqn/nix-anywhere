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
            pmset -a hibernatemode 0

            pmset -a sleep 0
            pmset -a disksleep 0
            pmset -a displaysleep 0

            pmset -a powernap 0

            pmset -a autopoweroff 0

            pmset -a standby 0

            pmset -a lowpowermode 0

            pmset -a gpuswitch 0

            pmset -a sms 0

            defaults write com.apple.assistant.support "Assistant Enabled" -bool false

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
  };

  environment.etc = {
    "sysctl.conf".text = ''
      kern.maxfiles=524288
      kern.maxfilesperproc=262144
      kern.maxproc=2048
      kern.maxprocperuid=1024
    '';
  };

  environment.systemPackages = with pkgs; [
    bottom
  ];
}
