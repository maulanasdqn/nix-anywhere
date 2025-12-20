{
  username,
  ...
}:
{
  imports = [
    ./aliases.nix
  ];

  home-manager.users.${username} = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "z"
          "docker"
          "kubectl"
        ];
      };

      initContent = ''
        bindkey '^[[A' history-search-backward
        bindkey '^[[B' history-search-forward

        if command -v fzf &> /dev/null; then
          eval "$(fzf --zsh)"
        fi
      '';
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
