{ pkgs, ... }:
let
  skhdConfig = pkgs.writeText "skhdrc" ''
    # Open Ghostty (cmd + shift + enter)
    cmd + shift - return : open -a Ghostty

    # Switch to workspace (cmd + number)
    cmd - 1 : /usr/local/bin/yabai -m space --focus 1
    cmd - 2 : /usr/local/bin/yabai -m space --focus 2
    cmd - 3 : /usr/local/bin/yabai -m space --focus 3
    cmd - 4 : /usr/local/bin/yabai -m space --focus 4
    cmd - 5 : /usr/local/bin/yabai -m space --focus 5
    cmd - 6 : /usr/local/bin/yabai -m space --focus 6
    cmd - 7 : /usr/local/bin/yabai -m space --focus 7
    cmd - 8 : /usr/local/bin/yabai -m space --focus 8
    cmd - 9 : /usr/local/bin/yabai -m space --focus 9

    # Move window to workspace (cmd + shift + number)
    cmd + shift - 1 : /usr/local/bin/yabai -m window --space 1; /usr/local/bin/yabai -m space --focus 1
    cmd + shift - 2 : /usr/local/bin/yabai -m window --space 2; /usr/local/bin/yabai -m space --focus 2
    cmd + shift - 3 : /usr/local/bin/yabai -m window --space 3; /usr/local/bin/yabai -m space --focus 3
    cmd + shift - 4 : /usr/local/bin/yabai -m window --space 4; /usr/local/bin/yabai -m space --focus 4
    cmd + shift - 5 : /usr/local/bin/yabai -m window --space 5; /usr/local/bin/yabai -m space --focus 5
    cmd + shift - 6 : /usr/local/bin/yabai -m window --space 6; /usr/local/bin/yabai -m space --focus 6
    cmd + shift - 7 : /usr/local/bin/yabai -m window --space 7; /usr/local/bin/yabai -m space --focus 7
    cmd + shift - 8 : /usr/local/bin/yabai -m window --space 8; /usr/local/bin/yabai -m space --focus 8
    cmd + shift - 9 : /usr/local/bin/yabai -m window --space 9; /usr/local/bin/yabai -m space --focus 9

    # Focus window (cmd + hjkl)
    cmd - h : /usr/local/bin/yabai -m window --focus west
    cmd - j : /usr/local/bin/yabai -m window --focus south
    cmd - k : /usr/local/bin/yabai -m window --focus north
    cmd - l : /usr/local/bin/yabai -m window --focus east

    # Swap window (cmd + shift + hjkl)
    cmd + shift - h : /usr/local/bin/yabai -m window --swap west
    cmd + shift - j : /usr/local/bin/yabai -m window --swap south
    cmd + shift - k : /usr/local/bin/yabai -m window --swap north
    cmd + shift - l : /usr/local/bin/yabai -m window --swap east

    # Move window (cmd + ctrl + hjkl)
    cmd + ctrl - h : /usr/local/bin/yabai -m window --warp west
    cmd + ctrl - j : /usr/local/bin/yabai -m window --warp south
    cmd + ctrl - k : /usr/local/bin/yabai -m window --warp north
    cmd + ctrl - l : /usr/local/bin/yabai -m window --warp east

    # Resize windows (cmd + alt + hjkl)
    cmd + alt - h : /usr/local/bin/yabai -m window --resize left:-50:0; /usr/local/bin/yabai -m window --resize right:-50:0
    cmd + alt - j : /usr/local/bin/yabai -m window --resize bottom:0:50; /usr/local/bin/yabai -m window --resize top:0:50
    cmd + alt - k : /usr/local/bin/yabai -m window --resize top:0:-50; /usr/local/bin/yabai -m window --resize bottom:0:-50
    cmd + alt - l : /usr/local/bin/yabai -m window --resize right:50:0; /usr/local/bin/yabai -m window --resize left:50:0

    # Toggle float and center (cmd + t)
    cmd - t : /usr/local/bin/yabai -m window --toggle float; /usr/local/bin/yabai -m window --grid 4:4:1:1:2:2

    # Toggle fullscreen (cmd + shift + f)
    cmd + shift - f : /usr/local/bin/yabai -m window --toggle zoom-fullscreen

    # Balance windows (cmd + b)
    cmd - b : /usr/local/bin/yabai -m space --balance

    # Rotate layout (cmd + r)
    cmd - r : /usr/local/bin/yabai -m space --rotate 90

    # Toggle split orientation (cmd + e)
    cmd - e : /usr/local/bin/yabai -m window --toggle split

    # Kill focused window (cmd + shift + q)
    cmd + shift - q : /usr/local/bin/yabai -m window --close
  '';
in
{
  # Install skhd package but don't use the built-in service
  # (the built-in service uses nix store paths which break accessibility permissions)
  environment.systemPackages = [ pkgs.skhd ];

  # Custom launchd service using stable symlink path
  launchd.user.agents.skhd = {
    serviceConfig = {
      ProgramArguments = [ "/usr/local/bin/skhd" "-c" "${skhdConfig}" ];
      EnvironmentVariables = {
        PATH = "/usr/local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/skhd.out.log";
      StandardErrorPath = "/tmp/skhd.err.log";
    };
  };
}
