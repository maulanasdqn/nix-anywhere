{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./keybindings.nix
    ./theme.nix
  ];

  home-manager.users.${username} = {
    # Tmux startup script
    home.file.".local/bin/tmux-startup" = {
      executable = true;
      text = ''
        #!/bin/bash

        # Define sessions
        declare -A SESSIONS
        SESSIONS=(
          ["Nix Darwin"]="$HOME/.config/nix"
          ["MRScraperV3"]="$HOME/Development/mrscraper/mrscraper-v3"
          ["MRScraperWEB"]="$HOME/Development/mrscraper/mrscraper-web"
          ["YDM FE"]="$HOME/Development/bsm/yes-date-me-frontend"
          ["YDM BE"]="$HOME/Development/bsm/yes-date-me-backend"
          ["ECHO"]="$HOME/Development/bsm/social-media-automation"
          ["BSM Landing"]="$HOME/Development/bsm/bsmart-landing"
        )

        # Session order
        SESSION_ORDER=("Nix Darwin" "MRScraperV3" "MRScraperWEB" "YDM FE" "YDM BE" "ECHO" "BSM Landing")

        # Create sessions if they don't exist
        for name in "''${SESSION_ORDER[@]}"; do
          dir="''${SESSIONS[$name]}"
          if ! tmux has-session -t "$name" 2>/dev/null; then
            if [ -d "$dir" ]; then
              tmux new-session -d -s "$name" -c "$dir"
            else
              tmux new-session -d -s "$name" -c "$HOME"
            fi
          fi
        done

        # Attach to first session if not already in tmux
        if [ -z "$TMUX" ]; then
          tmux attach-session -t "Nix Darwin"
        fi
      '';
    };

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 10000;
      escapeTime = 0;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";

      extraConfig = ''
        set -g default-command "${pkgs.zsh}/bin/zsh"
        set -g default-shell "${pkgs.zsh}/bin/zsh"
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -g renumber-windows on
        set -g allow-rename off
        set -g mouse on
        setw -g mode-keys vi
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];
    };
  };
}
