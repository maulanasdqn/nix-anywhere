{ pkgs, ... }:
{
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;

    config = {
      # Layout
      layout = "bsp";
      auto_balance = "off";

      # External bar (sketchybar)
      external_bar = "all:32:0";

      # Padding and gaps
      top_padding = 5;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;

      # Mouse
      mouse_follows_focus = "off";
      focus_follows_mouse = "autofocus";
      mouse_modifier = "cmd";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # Window appearance
      window_placement = "second_child";
      window_shadow = "float";
      window_opacity = "off";
      split_ratio = 0.5;
    };

    extraConfig = ''
      # Load scripting addition
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      # Rules for floating windows
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Karabiner-Elements$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off
      yabai -m rule --add app="^Finder$" title="(Copy|Connect|Move|Info|Pref)" manage=off
      yabai -m rule --add app="^Alfred Preferences$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^Discord$" title="^Discord Updater$" manage=off

      # Create spaces if they don't exist (need at least 9 for workspaces)
      for i in $(seq 1 9); do
        yabai -m space $i --label $i 2>/dev/null || true
      done

      # Signal sketchybar on space change
      yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"
      yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"

      echo "yabai configuration loaded..."
    '';
  };
}
