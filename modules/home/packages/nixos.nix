{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username}.home = {
    packages = with pkgs; [
      # File tools
      eza
      bat
      fzf
      zoxide
      ripgrep
      fd
      jq
      yq

      # Development tools
      nodejs_22
      pnpm
      bun
      go
      python3

      # Container tools
      docker-compose
      lazydocker

      # Git tools
      lazygit
      gh
      delta

      # System tools
      ncdu
      duf
      procs
      bottom
      htop
      tldr
      brightnessctl
      swayosd

      # Network tools
      httpie
      xh

      # Archive tools
      p7zip
      unrar

      # Communication
      slack

      # Browser
      microsoft-edge

      # Misc
      imagemagick
      ffmpeg
    ];

    sessionVariables = {
      EDITOR = "nvim";
      GOPATH = "$HOME/go";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.bun/bin"
    ];
  };
}
