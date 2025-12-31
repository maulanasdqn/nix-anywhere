{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    # GTK Theme (Light Pink)
    gtk = {
      enable = true;

      theme = {
        name = "Catppuccin-Latte-Standard-Pink-Light";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          variant = "latte";
        };
      };

      iconTheme = {
        name = "Papirus-Light";
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = "latte";
          accent = "pink";
        };
      };

      cursorTheme = {
        name = "catppuccin-mocha-pink-cursors";
        package = pkgs.catppuccin-cursors.mochaPink;
        size = 24;
      };

      font = {
        name = "Quicksand";
        size = 11;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = false;
        gtk-decoration-layout = "appmenu:none";
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = false;
        gtk-decoration-layout = "appmenu:none";
      };
    };

    # QT Theme
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        name = "kvantum";
      };
    };

    # Kvantum theme config
    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      kdePackages.qtstyleplugin-kvantum
      catppuccin-kvantum
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-latte-pink
    '';

    # Cursor theme for Hyprland (dark pink for visibility)
    home.pointerCursor = {
      name = "catppuccin-mocha-pink-cursors";
      package = pkgs.catppuccin-cursors.mochaPink;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # Environment variables for theming
    home.sessionVariables = {
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "catppuccin-mocha-pink-cursors";
      GTK_THEME = "Catppuccin-Latte-Standard-Pink-Light";
    };

    # Cute preppy lipstick wallpaper
    home.file.".config/hypr/wallpaper.jpg".source = ../../../wallpaper.jpg;
  };
}
