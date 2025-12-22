{ pkgs, config, ... }:
let
  yabaiConfig = pkgs.writeScript "yabairc" ''
    #!/bin/bash

    # Load scripting addition
    sudo /usr/local/bin/yabai --load-sa
    /usr/local/bin/yabai -m signal --add event=dock_did_restart action="sudo /usr/local/bin/yabai --load-sa"

    # Layout
    /usr/local/bin/yabai -m config layout bsp
    /usr/local/bin/yabai -m config auto_balance off

    # External bar (sketchybar)
    /usr/local/bin/yabai -m config external_bar all:32:0

    # Padding and gaps
    /usr/local/bin/yabai -m config top_padding 5
    /usr/local/bin/yabai -m config bottom_padding 10
    /usr/local/bin/yabai -m config left_padding 10
    /usr/local/bin/yabai -m config right_padding 10
    /usr/local/bin/yabai -m config window_gap 10

    # Mouse
    /usr/local/bin/yabai -m config mouse_follows_focus off
    /usr/local/bin/yabai -m config focus_follows_mouse autofocus
    /usr/local/bin/yabai -m config mouse_modifier cmd
    /usr/local/bin/yabai -m config mouse_action1 move
    /usr/local/bin/yabai -m config mouse_action2 resize
    /usr/local/bin/yabai -m config mouse_drop_action swap

    # Window appearance
    /usr/local/bin/yabai -m config window_placement second_child
    /usr/local/bin/yabai -m config window_shadow float
    /usr/local/bin/yabai -m config window_opacity off
    /usr/local/bin/yabai -m config split_ratio 0.5

    # Rules for floating windows
    /usr/local/bin/yabai -m rule --add app="^System Preferences$" manage=off
    /usr/local/bin/yabai -m rule --add app="^System Settings$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Calculator$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Karabiner-Elements$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Archive Utility$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Finder$" title="(Copy|Connect|Move|Info|Pref)" manage=off
    /usr/local/bin/yabai -m rule --add app="^Alfred Preferences$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Raycast$" manage=off
    /usr/local/bin/yabai -m rule --add app="^Discord$" title="^Discord Updater$" manage=off

    # Create spaces if they don't exist (need at least 9 for workspaces)
    for i in $(seq 1 9); do
      /usr/local/bin/yabai -m space $i --label $i 2>/dev/null || true
    done

    # Signal sketchybar on space change
    /usr/local/bin/yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"
    /usr/local/bin/yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"

    echo "yabai configuration loaded..."
  '';
in
{
  # Install yabai package but don't use the built-in service
  # (the built-in service uses nix store paths which break accessibility permissions)
  environment.systemPackages = [ pkgs.yabai ];

  # Enable scripting addition sudoers entry
  environment.etc."sudoers.d/yabai".text = ''
    %admin ALL=(root) NOPASSWD: sha256:${builtins.hashFile "sha256" "${pkgs.yabai}/bin/yabai"} ${pkgs.yabai}/bin/yabai --load-sa
    %admin ALL=(root) NOPASSWD: /usr/local/bin/yabai --load-sa
  '';

  # Custom launchd service using stable symlink path
  launchd.user.agents.yabai = {
    serviceConfig = {
      ProgramArguments = [ "/usr/local/bin/yabai" "-c" "${yabaiConfig}" ];
      EnvironmentVariables = {
        PATH = "/usr/local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/yabai.out.log";
      StandardErrorPath = "/tmp/yabai.err.log";
    };
  };
}
