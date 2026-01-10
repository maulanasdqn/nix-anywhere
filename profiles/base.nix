{
  lib,
  pkgs,
  username,
  sshKeys,
  ...
}:
let
  # Fallback SSH key in case sshKeys is empty
  fallbackKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer";
  allSshKeys = if sshKeys == [] then [ fallbackKey ] else sshKeys;
in
{
  # Ensure username is never empty
  assertions = [
    {
      assertion = username != "";
      message = "username must not be empty";
    }
  ];

  time.timeZone = lib.mkDefault "Asia/Jakarta";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  boot = {
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    tmp.cleanOnBoot = true;
  };

  users.mutableUsers = true;

  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = allSshKeys;
    createHome = true;
    home = "/home/${username}";
  };

  users.users.root.openssh.authorizedKeys.keys = allSshKeys;

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  system.stateVersion = "25.05";
}
