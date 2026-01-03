{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.wofi = {
      enable = true;

      settings = {
        width = 600;
        height = 360;
        location = "center";
        show = "drun";
        prompt = "Search";
        filter_rate = 100;
        allow_markup = true;
        no_actions = true;
        halign = "fill";
        orientation = "vertical";
        content_halign = "fill";
        insensitive = true;
        allow_images = true;
        image_size = 40;
        gtk_dark = false;
        dynamic_lines = true;
        columns = 1;
        hide_scroll = true;
        matching = "fuzzy";
        sort_order = "alphabetical";
      };

      style = ''
        * {
          font-family: "SF Pro Display", "Quicksand", "Inter", sans-serif;
          font-size: 15px;
        }

        window {
          background: #fffafb;
          border: 1px solid rgba(255, 105, 180, 0.3);
          border-radius: 16px;
        }

        #outer-box {
          margin: 0;
          padding: 0;
        }

        #input {
          background: transparent;
          border: none;
          border-bottom: 1px solid rgba(255, 182, 193, 0.4);
          border-radius: 0;
          padding: 20px 24px;
          color: #5d4057;
          font-size: 22px;
          font-weight: 300;
          margin: 0;
        }

        #input:focus {
          border-bottom: 1px solid #ff69b4;
          box-shadow: none;
          outline: none;
        }

        #input image {
          color: #ff69b4;
          margin-right: 12px;
        }

        #input:first-child > :first-child {
          min-height: 28px;
          min-width: 28px;
        }

        #scroll {
          background: transparent;
          margin: 0;
          padding: 8px 0;
        }

        #inner-box {
          background: transparent;
          padding: 0 8px;
        }

        #entry {
          padding: 12px 16px;
          margin: 2px 8px;
          border-radius: 10px;
          background: transparent;
          transition: all 0.15s ease;
        }

        #entry:hover {
          background: rgba(255, 182, 193, 0.25);
        }

        #entry:selected {
          background: linear-gradient(135deg, #ff69b4, #ff85a2);
          box-shadow: 0 2px 8px rgba(255, 105, 180, 0.3);
        }

        #entry:selected #text {
          color: #ffffff;
          font-weight: 500;
        }

        #text {
          color: #5d4057;
          margin-left: 12px;
        }

        #text:selected {
          color: #ffffff;
        }

        #img {
          margin-right: 4px;
          border-radius: 8px;
        }
      '';
    };

    home.file.".local/bin/wofi-power" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        entries=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

        selected=$(echo -e $entries | wofi --dmenu --prompt "Power Menu" --width 250 --height 280 --cache-file /dev/null)

        case $selected in
          " Lock")
            hyprlock;;
          " Logout")
            hyprctl dispatch exit;;
          " Suspend")
            systemctl suspend;;
          " Reboot")
            systemctl reboot;;
          " Shutdown")
            systemctl poweroff;;
        esac
      '';
    };
  };
}
