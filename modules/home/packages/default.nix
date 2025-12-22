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
      n8n
    ];

    home.sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
      # n8n configuration
      DB_SQLITE_POOL_SIZE = "4";
      N8N_RUNNERS_ENABLED = "true";
      N8N_BLOCK_ENV_ACCESS_IN_NODE = "false";
      N8N_GIT_NODE_DISABLE_BARE_REPOS = "true";
    };

    home.sessionPath = [
      "$HOME/.volta/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
      "$HOME/.deno/bin"
    ];
  };
}
