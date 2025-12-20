{ username, pkgs, ... }:
{
  home-manager.users.${username} = { config, ... }: {
    home.packages = with pkgs; [
      sketchybar
    ];

    # Plugin scripts
    home.file.".config/sketchybar/plugins/space.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        if [ "$SELECTED" = "true" ]; then
          sketchybar --set $NAME background.drawing=on icon.color=0xff191724
        else
          sketchybar --set $NAME background.drawing=off icon.color=0xffe0def4
        fi
      '';
    };

    home.file.".config/sketchybar/plugins/front_app.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        sketchybar --set $NAME label="$INFO"
      '';
    };

    home.file.".config/sketchybar/plugins/clock.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        sketchybar --set $NAME label="$(date '+%H:%M')"
      '';
    };

    home.file.".config/sketchybar/plugins/date.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        sketchybar --set $NAME label="$(date '+%a %d %b')"
      '';
    };

    home.file.".config/sketchybar/plugins/battery.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
        CHARGING=$(pmset -g batt | grep 'AC Power')

        if [ "$PERCENTAGE" = "" ]; then
          exit 0
        fi

        case "''${PERCENTAGE}" in
          9[0-9]|100) ICON="󰁹" ;;
          [6-8][0-9]) ICON="󰂀" ;;
          [3-5][0-9]) ICON="󰁾" ;;
          [1-2][0-9]) ICON="󰁻" ;;
          *) ICON="󰁺" ;;
        esac

        if [[ "$CHARGING" != "" ]]; then
          ICON="󰂄"
        fi

        sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
      '';
    };

    home.file.".config/sketchybar/plugins/cpu.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        CPU=$(top -l 2 | grep -E "^CPU" | tail -1 | awk '{print $3}' | sed 's/%//')
        sketchybar --set $NAME label="''${CPU}%"
      '';
    };

    home.file.".config/sketchybar/plugins/memory.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | tr -d '%')
        sketchybar --set $NAME label="''${MEMORY}%"
      '';
    };

    home.file.".config/sketchybar/plugins/wifi.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        WIFI=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A 1 "Current Network Information:" | grep -v "Current Network" | grep -v "Network Type" | head -1 | sed 's/://g' | xargs)

        if [ "$WIFI" = "" ]; then
          ICON="󰤭"
          LABEL="Off"
        else
          ICON="󰤨"
          LABEL="$WIFI"
        fi

        sketchybar --set $NAME icon="$ICON" label="$LABEL"
      '';
    };

    home.file.".config/sketchybar/plugins/volume.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        VOLUME=$(osascript -e 'output volume of (get volume settings)')
        MUTED=$(osascript -e 'output muted of (get volume settings)')

        if [ "$MUTED" = "true" ]; then
          ICON="󰝟"
          LABEL="Mute"
        elif [ "$VOLUME" -eq 0 ]; then
          ICON="󰕿"
          LABEL="0%"
        elif [ "$VOLUME" -lt 30 ]; then
          ICON="󰖀"
          LABEL="''${VOLUME}%"
        elif [ "$VOLUME" -lt 70 ]; then
          ICON="󰕾"
          LABEL="''${VOLUME}%"
        else
          ICON="󰕾"
          LABEL="''${VOLUME}%"
        fi

        sketchybar --set $NAME icon="$ICON" label="$LABEL"
      '';
    };
  };
}
