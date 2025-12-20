{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      ripgrep
      fd
      fzf
      eza
      bat
      htop
      jq
      tree
      volta
      bun
      deno
      rustup
      slack
      speedtest-cli
    ];

    home.sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
    };

    home.sessionPath = [
      "$HOME/.volta/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
      "$HOME/.deno/bin"
    ];
  };
}
