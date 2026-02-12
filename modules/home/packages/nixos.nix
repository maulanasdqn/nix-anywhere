{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username}.home = {
    packages = with pkgs; [
      eza
      bat
      fzf
      zoxide
      ripgrep
      fd
      jq
      yq

      nodejs_22
      pnpm
      bun
      go
      python3

      docker-compose
      lazydocker

      lazygit
      gh
      delta

      ncdu
      duf
      procs
      bottom
      htop
      tldr
      brightnessctl
      swayosd

      httpie
      xh
      postman

      p7zip
      unrar

      slack

      google-chrome
      antigravity

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
