{ pkgs, ... }:

{
  environment.packages = with pkgs; [
    git
    curl
    wget
    jq
    ripgrep
    fd
    fzf
    eza
    bat
    htop
    tree
    unzip
    gzip
    neovim
    tmux
    openssh
    nixfmt
    zsh
    starship
  ];

  environment.etcBackupExtension = ".bak";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "Asia/Jakarta";

  system.stateVersion = "24.05";
}
