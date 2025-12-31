{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./waybar.nix
    ./wofi.nix
    ./theme.nix
  ];

  home-manager.users.${username} = {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        # Light baby pink color palette
        "$pink" = "rgb(ff85a2)";
        "$hotpink" = "rgb(ff69b4)";
        "$lightpink" = "rgb(ffc0cb)";
        "$babypink" = "rgb(ffebee)";
        "$rose" = "rgb(fce4ec)";
        "$white" = "rgb(ffffff)";
        "$cream" = "rgb(fff5f7)";
        "$text" = "rgb(5d4057)";
        "$surface" = "rgb(ffe4e9)";

        # Monitor config with scaling (adjust scale as needed: 1, 1.25, 1.5, 2)
        monitor = ",preferred,auto,1.25";

        # Autostart (waybar started via systemd, mako via home-manager service)
        exec-once = [
          "hyprctl setcursor catppuccin-mocha-pink-cursors 24"
          "hyprpaper"
          "swayosd-server"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
        ];

        # General settings
        general = {
          gaps_in = 8;
          gaps_out = 16;
          border_size = 3;
          "col.active_border" = "$hotpink $pink 45deg";
          "col.inactive_border" = "$lightpink";
          layout = "dwindle";
          allow_tearing = false;
        };

        # Decoration (blur, rounding, shadows)
        decoration = {
          rounding = 16;
          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            new_optimizations = true;
            xray = true;
          };
          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
            color = "rgba(ff69b433)";
          };
        };

        # Animations (cute and bouncy)
        animations = {
          enabled = true;
          bezier = [
            "cute, 0.68, -0.55, 0.265, 1.55"
            "smooth, 0.25, 0.1, 0.25, 1"
            "bounce, 0.68, -0.6, 0.32, 1.6"
            "fadeBounce, 0.36, 0, 0.66, -0.56"
          ];
          animation = [
            "windows, 1, 5, bounce, slide"
            "windowsOut, 1, 5, cute, slide"
            "border, 1, 10, smooth"
            "borderangle, 1, 100, smooth, loop"
            "fade, 1, 5, smooth"
            "workspaces, 1, 5, smooth, slidefade 20%"
          ];
        };

        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # Master layout
        master = {
          new_status = "master";
        };

        # Input settings
        input = {
          kb_layout = "us";
          kb_options = "caps:escape";
          follow_mouse = 1;
          sensitivity = 0.5;
          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
          };
        };

        # Cursor
        cursor = {
          default_monitor = "";
        };

        env = [
          "XCURSOR_THEME,catppuccin-mocha-pink-cursors"
          "XCURSOR_SIZE,24"
        ];

        # Misc
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        # Window rules
        windowrulev2 = [
          "float, class:^(pavucontrol)$"
          "float, class:^(nm-connection-editor)$"
          "float, class:^(org.gnome.Calculator)$"
          "float, title:^(Picture-in-Picture)$"
          "opacity 0.95, class:^(kitty)$"
          "opacity 0.95, class:^(Alacritty)$"
          "opacity 0.9, class:^(code)$"
        ];

        # Layer rules
        layerrule = [
          "blur, waybar"
          "blur, wofi"
          "ignorezero, waybar"
          "ignorezero, wofi"
        ];

        # Keybindings
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$menu" = "wofi --show drun";
        "$browser" = "firefox";
        "$fileManager" = "nautilus";

        bind = [
          # Applications
          "$mod, Return, exec, $terminal"
          "$mod, Space, exec, $menu"
          "$mod, D, exec, $menu"
          "$mod, E, exec, $fileManager"
          "$mod, B, exec, $browser"

          # Window management
          "$mod SHIFT, Q, killactive"
          "$mod SHIFT, E, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"

          # Focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Special workspace (scratchpad)
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Screenshots
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "SHIFT, Print, exec, grim - | wl-copy"

          # Clipboard history
          "$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

          # Color picker
          "$mod SHIFT, C, exec, hyprpicker -a"

          # Lock screen
          "$mod, X, exec, hyprlock"
        ];

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Volume keys (with OSD feedback, 2% steps)
        bindel = [
          ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume +2"
          ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -2"
        ];

        bindl = [
          ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
          ", switch:on:Lid Switch, exec, systemctl suspend"
        ];

        # Brightness keys (with OSD feedback, 2% steps)
        binde = [
          ", XF86MonBrightnessUp, exec, swayosd-client --brightness +2"
          ", XF86MonBrightnessDown, exec, swayosd-client --brightness -2"
        ];

        # Touchpad gesture for workspace switching
        gesture = [
          "3, horizontal, workspace"
        ];
      };
    };

    # Hyprpaper wallpaper config
    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = ~/.config/hypr/wallpaper.jpg
      wallpaper = ,~/.config/hypr/wallpaper.jpg
      splash = false
    '';

    # Hyprlock config (light baby pink themed)
    home.file.".config/hypr/hyprlock.conf".text = ''
      background {
        monitor =
        path = ~/.config/hypr/wallpaper.jpg
        blur_passes = 3
        blur_size = 8
        brightness = 1.0
      }

      input-field {
        monitor =
        size = 300, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        outer_color = rgb(ff69b4)
        inner_color = rgb(fff5f7)
        font_color = rgb(5d4057)
        fade_on_empty = false
        placeholder_text = <span foreground="##ff69b4">Password...</span>
        hide_input = false
        position = 0, -20
        halign = center
        valign = center
      }

      label {
        monitor =
        text = Hi Cutie!
        color = rgb(ff69b4)
        font_size = 48
        font_family = JetBrainsMono Nerd Font
        position = 0, 150
        halign = center
        valign = center
      }

      label {
        monitor =
        text = $TIME
        color = rgb(5d4057)
        font_size = 96
        font_family = JetBrainsMono Nerd Font
        position = 0, 50
        halign = center
        valign = center
      }
    '';

    # Mako notification daemon (light pink themed)
    services.mako = {
      enable = true;
      settings = {
        background-color = "#fff5f7";
        text-color = "#5d4057";
        border-color = "#ff69b4";
        border-size = 3;
        border-radius = 12;
        default-timeout = 5000;
        font = "JetBrainsMono Nerd Font 11";
        width = 350;
        height = 150;
        margin = "16";
        padding = "12";
      };
    };

    # Install additional packages
    home.packages = with pkgs; [
      kitty
      pavucontrol
      networkmanagerapplet
    ];

    # Kitty terminal (light baby pink themed)
    programs.kitty = {
      enable = true;
      settings = {
        # Font
        font_family = "JetBrainsMono Nerd Font";
        font_size = 14;

        # Light pink theme colors
        background = "#fff5f7";
        foreground = "#5d4057";
        cursor = "#ff69b4";
        cursor_text_color = "#fff5f7";
        selection_background = "#ffc0cb";
        selection_foreground = "#5d4057";

        # Tab bar
        active_tab_background = "#ff69b4";
        active_tab_foreground = "#ffffff";
        inactive_tab_background = "#ffe4e9";
        inactive_tab_foreground = "#5d4057";

        # Normal colors
        color0 = "#5d4057";
        color1 = "#e84a72";
        color2 = "#7cb879";
        color3 = "#d4a023";
        color4 = "#5c9fd4";
        color5 = "#ff69b4";
        color6 = "#b47ead";
        color7 = "#fce4ec";

        # Bright colors
        color8 = "#7d6077";
        color9 = "#ff6b8a";
        color10 = "#8ed88b";
        color11 = "#e8b84a";
        color12 = "#7ab8e8";
        color13 = "#ff85c1";
        color14 = "#d49bcf";
        color15 = "#ffffff";

        # Window
        background_opacity = "0.95";
        window_padding_width = 12;
        confirm_os_window_close = 0;

        # Other
        enable_audio_bell = false;
        shell_integration = "enabled";
      };
      keybindings = {
        # Claude Code Shift+Enter binding
        "shift+enter" = "send_text all \\x1b[13;2u";
      };
    };

    # SwayOSD styling (pink theme)
    home.file.".config/swayosd/style.css".text = ''
      window {
        background: rgba(255, 250, 251, 0.95);
        border-radius: 20px;
        border: 2px solid rgba(255, 105, 180, 0.4);
        padding: 12px 20px;
      }

      #container {
        margin: 16px;
      }

      image {
        margin-right: 12px;
        color: #ff69b4;
      }

      progressbar {
        min-height: 8px;
        border-radius: 4px;
        background: #ffe4e9;
      }

      progressbar:disabled {
        background: #ffc0cb;
      }

      progressbar progress {
        min-height: 8px;
        border-radius: 4px;
        background: linear-gradient(90deg, #ff69b4, #ff85a2);
      }

      label {
        color: #5d4057;
        font-family: "Quicksand", sans-serif;
        font-weight: 600;
        font-size: 14px;
      }
    '';
  };
}
