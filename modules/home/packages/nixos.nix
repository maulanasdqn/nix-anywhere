{
  pkgs,
  username,
  claude-code,
  claude-desktop,
  ...
}:
{
  home-manager.users.${username}.home = {
    packages = with pkgs; [
      claude-code.packages.${pkgs.system}.default
      claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
      (callPackage ../../../pkgs/helium-browser { })

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

      p7zip
      unrar

      slack
      discord

      brave
      google-chrome

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
