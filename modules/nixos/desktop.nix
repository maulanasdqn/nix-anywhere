{
  pkgs,
  ...
}:
{
  services.xserver = {
    enable = true;

    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Touchpad settings via libinput
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
    };
  };

  # GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Exclude some default GNOME packages
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    epiphany
    geary
    totem
  ];

  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # Packages needed for Hyprland
  environment.systemPackages = with pkgs; [
    # Hyprland essentials
    hyprpaper
    hyprlock
    hypridle
    hyprpicker

    # Screenshot & utilities
    grim
    slurp
    wl-clipboard
    cliphist

    # Notifications
    libnotify
    mako

    # File manager
    nautilus

    # Authentication
    polkit_gnome
  ];

  # Enable polkit for authentication dialogs
  security.polkit.enable = true;

  # Power management and lid settings
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Enable suspend/hibernate
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.login1.suspend" ||
          action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
          action.id == "org.freedesktop.login1.hibernate" ||
          action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
      {
        return polkit.Result.YES;
      }
    });
  '';

  # Disable USB wake to prevent immediate wake after suspend
  systemd.services.disable-usb-wake = {
    description = "Disable USB wake from suspend";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for device in XHC0 XHC1 GP17; do
        if grep -q "$device.*enabled" /proc/acpi/wakeup; then
          echo $device > /proc/acpi/wakeup
        fi
      done
    '';
  };
}
