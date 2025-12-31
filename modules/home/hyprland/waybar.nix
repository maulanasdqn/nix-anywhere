{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username}.programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 42;
        spacing = 8;
        margin-top = 8;
        margin-left = 16;
        margin-right = 16;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "battery"
          "custom/sleep"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "";
            "9" = "";
            "10" = "";
            urgent = "";
            default = "";
            empty = "";
          };
          on-click = "activate";
          sort-by-number = true;
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 40;
          separate-outputs = true;
        };

        clock = {
          format = "🎀 {:%H:%M}";
          format-alt = "💖 {:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              months = "<span color='#ff69b4'><b>{}</b></span>";
              days = "<span color='#ffb6c1'>{}</span>";
              weeks = "<span color='#da70d6'>W{}</span>";
              weekdays = "<span color='#ff1493'>{}</span>";
              today = "<span color='#ff1493'><b><u>{}</u></b></span>";
            };
          };
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "💗 {capacity}%";
          format-plugged = "🔌 {capacity}%";
          format-icons = [ "🤍" "🩷" "💕" "💖" "💝" ];
        };

        network = {
          format-wifi = "🌸 {essid}";
          format-ethernet = "🦋 {ipaddr}";
          format-disconnected = "💔 Offline";
          tooltip-format-wifi = "{essid} ({signalStrength}%) - {ipaddr}";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "🎧 {volume}%";
          format-muted = "🔇 Muted";
          format-icons = {
            default = [ "🔈" "🔉" "🔊" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 8;
          icon-size = 18;
        };

        "custom/sleep" = {
          format = "😴";
          tooltip-format = "Sleep";
          on-click = "systemctl suspend";
        };

        "custom/power" = {
          format = "🩷";
          tooltip = false;
          on-click = "wofi-power";
        };
      };
    };

    style = ''
      * {
        font-family: "Quicksand", "JetBrainsMono Nerd Font";
        font-size: 13px;
        font-weight: bold;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      window#waybar > box {
        background: rgba(255, 245, 247, 0.92);
        border: 2px solid #ff69b4;
        border-radius: 16px;
        padding: 4px 12px;
      }

      #workspaces {
        background: rgba(255, 228, 233, 0.9);
        border-radius: 12px;
        padding: 2px 8px;
        margin: 4px 0;
      }

      #workspaces button {
        color: #9d809a;
        padding: 4px 10px;
        margin: 0 3px;
        border-radius: 10px;
        background: transparent;
        border: none;
        transition: all 0.2s ease;
      }

      #workspaces button:hover {
        background: rgba(255, 105, 180, 0.2);
        color: #ff69b4;
      }

      #workspaces button.active {
        background: #ff69b4;
        color: #ffffff;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(255, 105, 180, 0.5);
        padding: 4px 12px;
        min-width: 32px;
        border-bottom: 3px solid #ffffff;
      }

      #workspaces button.urgent {
        background: #ff6b8a;
        color: #ffffff;
      }

      #window {
        color: #5d4057;
        padding: 0 12px;
        margin: 4px 0;
      }

      #clock {
        background: linear-gradient(45deg, #ff69b4, #ff85a2);
        color: #ffffff;
        padding: 4px 16px;
        border-radius: 12px;
        margin: 4px 0;
        box-shadow: 0 0 15px rgba(255, 105, 180, 0.3);
      }

      #battery,
      #network,
      #pulseaudio,
      #tray {
        background: rgba(255, 228, 233, 0.9);
        color: #5d4057;
        padding: 4px 12px;
        margin: 4px 4px;
        border-radius: 10px;
      }

      #battery:hover,
      #network:hover,
      #pulseaudio:hover {
        background: rgba(255, 105, 180, 0.3);
        color: #ff69b4;
      }

      #battery.warning {
        color: #d4a023;
      }

      #battery.critical {
        color: #e84a72;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background: #ff6b8a;
          color: #ffffff;
        }
      }

      #battery.charging {
        color: #7cb879;
      }

      #custom-power {
        background: linear-gradient(45deg, #ff69b4, #ff85a2);
        color: #ffffff;
        padding: 4px 12px;
        margin: 4px 0;
        border-radius: 10px;
        font-size: 16px;
      }

      #custom-power:hover {
        background: linear-gradient(45deg, #ff85a2, #ff69b4);
        box-shadow: 0 0 10px rgba(255, 105, 180, 0.5);
      }

      #tray {
        padding: 4px 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background: #ff6b8a;
      }

      tooltip {
        background: rgba(255, 245, 247, 0.98);
        border: 2px solid #ff69b4;
        border-radius: 12px;
      }

      tooltip label {
        color: #5d4057;
        padding: 8px;
      }
    '';
  };
}
