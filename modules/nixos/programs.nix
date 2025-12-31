{
  pkgs,
  ...
}:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix-ld for running dynamically linked executables (volta, etc.)
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

  # System-wide programs
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

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
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

    # GNOME extensions and tools
    gnome-tweaks
    dconf-editor
  ];

  # Enable CUPS for printing
  services.printing.enable = true;

  # System state version
  system.stateVersion = "25.05";
}
