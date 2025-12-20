{
  username,
  enableLaravel,
  sshKeys,
  lib,
  ...
}:
{
  imports = [
    ./packages
    ./git
    ./starship
    ./zsh
    ./neovim
    ./tmux
    ./docker
    ./ssh
    ./sops
    ./ghostty
    ./services
    ./wallpaper
    ./sketchybar
  ] ++ lib.optionals enableLaravel [
    ./laravel
  ];

  nixpkgs.config.allowUnfree = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username}.home.stateVersion = "24.11";
}
