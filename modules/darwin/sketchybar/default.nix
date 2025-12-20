{ pkgs, ... }:
{
  services.sketchybar = {
    enable = true;
    package = pkgs.sketchybar;

    config = ''
      #!/bin/bash

      # Color Palette (Rose Pine)
      export BLACK=0xff191724
      export WHITE=0xffe0def4
      export RED=0xffeb6f92
      export GREEN=0xff31748f
      export BLUE=0xff9ccfd8
      export YELLOW=0xfff6c177
      export ORANGE=0xffebbcba
      export MAGENTA=0xffc4a7e7
      export GREY=0xff6e6a86
      export TRANSPARENT=0x00000000
      export BAR_COLOR=0xff1f1d2e
      export ICON_COLOR=$WHITE
      export LABEL_COLOR=$WHITE

      # Bar Appearance
      sketchybar --bar \
        height=32 \
        color=$BAR_COLOR \
        shadow=on \
        position=top \
        sticky=on \
        padding_right=10 \
        padding_left=10 \
        corner_radius=0 \
        y_offset=0 \
        margin=0 \
        blur_radius=20 \
        notch_width=188

      # Default Item Appearance
      sketchybar --default \
        icon.font="Hack Nerd Font Mono:Bold:14.0" \
        icon.color=$ICON_COLOR \
        label.font="Hack Nerd Font Mono:Bold:12.0" \
        label.color=$LABEL_COLOR \
        background.color=$TRANSPARENT \
        background.corner_radius=5 \
        background.height=24 \
        padding_left=5 \
        padding_right=5 \
        label.padding_left=4 \
        label.padding_right=4 \
        icon.padding_left=4 \
        icon.padding_right=4

      # Nix logo
      sketchybar --add item nix left \
        --set nix \
          icon="󱄅" \
          icon.font="Hack Nerd Font Mono:Bold:18.0" \
          icon.color=$BLUE \
          label.drawing=off \
          click_script="open -a 'System Settings'"

      # Spaces (Workspaces) with icons
      # 1=terminal, 2=browser, 3=slack, 4=discord, 5=code, 6=folder, 7=music, 8=mail, 9=settings
      SPACE_ICONS=("󰆍" "󰖟" "󰒱" "󰙯" "󰨞" "󰉋" "󰎆" "󰇮" "󰒓")
      for i in {0..8}
      do
        sid=$((i+1))
        sketchybar --add space space.$sid left \
          --set space.$sid space=$sid \
            icon="''${SPACE_ICONS[$i]}" \
            icon.padding_left=10 \
            icon.padding_right=10 \
            background.color=$GREY \
            background.corner_radius=5 \
            background.height=22 \
            background.drawing=off \
            label.drawing=off \
            script="~/.config/sketchybar/plugins/space.sh" \
            click_script="yabai -m space --focus $sid"
      done

      # Left bracket for spaces
      sketchybar --add bracket spaces '/space\..*/' \
        --set spaces background.color=$BAR_COLOR

      # Front App (current focused app)
      sketchybar --add item front_app left \
        --set front_app \
          icon.drawing=off \
          label.font="JetBrainsMono Nerd Font:Bold:12.0" \
          label.color=$MAGENTA \
          script="~/.config/sketchybar/plugins/front_app.sh" \
        --subscribe front_app front_app_switched

      # Clock
      sketchybar --add item clock right \
        --set clock \
          icon="󰥔" \
          icon.color=$BLUE \
          update_freq=10 \
          script="~/.config/sketchybar/plugins/clock.sh"

      # Date
      sketchybar --add item date right \
        --set date \
          icon="󰃭" \
          icon.color=$YELLOW \
          update_freq=60 \
          script="~/.config/sketchybar/plugins/date.sh"

      # Volume
      sketchybar --add item volume right \
        --set volume \
          icon="󰕾" \
          icon.color=$GREEN \
          update_freq=5 \
          script="~/.config/sketchybar/plugins/volume.sh" \
          click_script="open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'"

      # WiFi
      sketchybar --add item wifi right \
        --set wifi \
          icon="󰤨" \
          icon.color=$MAGENTA \
          update_freq=30 \
          script="~/.config/sketchybar/plugins/wifi.sh" \
          click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"

      # Battery
      sketchybar --add item battery right \
        --set battery \
          icon.color=$GREEN \
          update_freq=120 \
          script="~/.config/sketchybar/plugins/battery.sh" \
        --subscribe battery system_woke power_source_change

      # CPU
      sketchybar --add item cpu right \
        --set cpu \
          icon="󰍛" \
          icon.color=$RED \
          update_freq=5 \
          script="~/.config/sketchybar/plugins/cpu.sh"

      # Memory
      sketchybar --add item memory right \
        --set memory \
          icon="󰘚" \
          icon.color=$ORANGE \
          update_freq=10 \
          script="~/.config/sketchybar/plugins/memory.sh"

      # Initialize
      sketchybar --update
    '';
  };
}
