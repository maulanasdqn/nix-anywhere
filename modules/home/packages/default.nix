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
      # n8n installed via npm for latest version (nixpkgs version is outdated)
    ];

    home.sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      # n8n configuration
      DB_SQLITE_POOL_SIZE = "4";
      N8N_RUNNERS_ENABLED = "true";
      N8N_BLOCK_ENV_ACCESS_IN_NODE = "false";
      N8N_GIT_NODE_DISABLE_BARE_REPOS = "true";
      N8N_CUSTOM_EXTENSIONS = "$HOME/Development/mrscraper/n8n-nodes-mrscraper";
    };

    home.sessionPath = [
      "$HOME/.volta/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
      "$HOME/.deno/bin"
      "$HOME/.npm-global/bin"
    ];
  };
}
