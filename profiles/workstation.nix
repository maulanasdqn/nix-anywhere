# Workstation profile - Desktop environment with development tools
{
  config,
  lib,
  pkgs,
  username,
  enableTilingWM,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # Additional workstation groups
  users.users.${username}.extraGroups = [
    "wheel"
    "networkmanager"
    "docker"
    "audio"
    "video"
  ];

  # NetworkManager for desktop
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.enable = true;

  # X11 and display
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Touchpad
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
    };
  };

  # GNOME Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Hyprland (optional)
  programs.hyprland = lib.mkIf enableTilingWM {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals =
      with pkgs;
      [
        xdg-desktop-portal-gtk
      ]
      ++ lib.optionals enableTilingWM [
        xdg-desktop-portal-hyprland
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

  programs.dconf.enable = true;

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # nix-ld for dynamically linked executables
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      libgcc
    ];
  };

  # Programs
  programs = {
    firefox.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Printing
  services.printing.enable = true;

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # Power management
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  security.polkit.enable = true;

  # Desktop packages
  environment.systemPackages =
    with pkgs;
    [
      # Essential tools
      wget
      curl
      unzip
      zip
      htop
      btop
      neofetch

      # Development
      gcc
      gnumake
      cmake

      # GNOME tools
      gnome-tweaks
      dconf-editor

      # File manager
      nautilus

      # Notifications
      libnotify

      # Authentication
      polkit_gnome
    ]
    ++ lib.optionals enableTilingWM [
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
      mako
    ];
}
