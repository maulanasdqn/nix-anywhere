# Minimal home-manager config for headless servers
{
  username,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git
    ./starship
    ./zsh
    ./neovim
    ./tmux
  ];

  home-manager.users.${username} = {
    home = {
      username = username;
      homeDirectory = "/home/${username}";
      stateVersion = "25.05";

      packages = with pkgs; [
        # CLI essentials
        eza
        bat
        fzf
        zoxide
        ripgrep
        fd
        jq
        yq

        # Git tools
        lazygit
        gh
        delta

        # System tools
        htop
        ncdu
        bottom

        # Network tools
        httpie
        curl
        wget
      ];

      sessionVariables = {
        EDITOR = "nvim";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    programs.home-manager.enable = true;

    # SSH config without 1Password agent (server doesn't have GUI)
    programs.ssh = {
      enable = true;
    };
  };
}
