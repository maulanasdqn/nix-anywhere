{ pkgs, ... }:
{
  services.skhd = {
    enable = true;
    package = pkgs.skhd;

    skhdConfig = ''
      # Open Ghostty (cmd + enter)
      cmd - return : open -a Ghostty

      # Switch to workspace (cmd + number)
      cmd - 1 : yabai -m space --focus 1
      cmd - 2 : yabai -m space --focus 2
      cmd - 3 : yabai -m space --focus 3
      cmd - 4 : yabai -m space --focus 4
      cmd - 5 : yabai -m space --focus 5
      cmd - 6 : yabai -m space --focus 6
      cmd - 7 : yabai -m space --focus 7
      cmd - 8 : yabai -m space --focus 8
      cmd - 9 : yabai -m space --focus 9

      # Move window to workspace (cmd + shift + number)
      cmd + shift - 1 : yabai -m window --space 1; yabai -m space --focus 1
      cmd + shift - 2 : yabai -m window --space 2; yabai -m space --focus 2
      cmd + shift - 3 : yabai -m window --space 3; yabai -m space --focus 3
      cmd + shift - 4 : yabai -m window --space 4; yabai -m space --focus 4
      cmd + shift - 5 : yabai -m window --space 5; yabai -m space --focus 5
      cmd + shift - 6 : yabai -m window --space 6; yabai -m space --focus 6
      cmd + shift - 7 : yabai -m window --space 7; yabai -m space --focus 7
      cmd + shift - 8 : yabai -m window --space 8; yabai -m space --focus 8
      cmd + shift - 9 : yabai -m window --space 9; yabai -m space --focus 9

      # Focus window (cmd + hjkl)
      cmd - h : yabai -m window --focus west
      cmd - j : yabai -m window --focus south
      cmd - k : yabai -m window --focus north
      cmd - l : yabai -m window --focus east

      # Swap window (cmd + shift + hjkl)
      cmd + shift - h : yabai -m window --swap west
      cmd + shift - j : yabai -m window --swap south
      cmd + shift - k : yabai -m window --swap north
      cmd + shift - l : yabai -m window --swap east

      # Move window (cmd + ctrl + hjkl)
      cmd + ctrl - h : yabai -m window --warp west
      cmd + ctrl - j : yabai -m window --warp south
      cmd + ctrl - k : yabai -m window --warp north
      cmd + ctrl - l : yabai -m window --warp east

      # Resize windows (cmd + alt + hjkl)
      cmd + alt - h : yabai -m window --resize left:-50:0; yabai -m window --resize right:-50:0
      cmd + alt - j : yabai -m window --resize bottom:0:50; yabai -m window --resize top:0:50
      cmd + alt - k : yabai -m window --resize top:0:-50; yabai -m window --resize bottom:0:-50
      cmd + alt - l : yabai -m window --resize right:50:0; yabai -m window --resize left:50:0

      # Toggle float and center (cmd + t)
      cmd - t : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2

      # Toggle fullscreen (cmd + shift + f)
      cmd + shift - f : yabai -m window --toggle zoom-fullscreen

      # Balance windows (cmd + b)
      cmd - b : yabai -m space --balance

      # Rotate layout (cmd + r)
      cmd - r : yabai -m space --rotate 90

      # Toggle split orientation (cmd + e)
      cmd - e : yabai -m window --toggle split

      # Kill focused window (cmd + shift + q)
      cmd + shift - q : yabai -m window --close
    '';
  };
}
