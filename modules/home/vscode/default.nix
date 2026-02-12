{
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          thorerik.hacker-theme

          jnoortheen.nix-ide
          rust-lang.rust-analyzer
          golang.go
          ms-python.python
          ms-python.vscode-pylance
          bradlc.vscode-tailwindcss
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode

          eamodio.gitlens
          mhutchie.git-graph

          usernamehw.errorlens
          christian-kohler.path-intellisense
          formulahendry.auto-rename-tag
          formulahendry.auto-close-tag

          yzhang.markdown-all-in-one
          redhat.vscode-yaml
          tamasfe.even-better-toml
        ];

        userSettings = {
          "workbench.colorTheme" = "Hacker";
          "workbench.iconTheme" = "material-icon-theme";

          "workbench.colorCustomizations" = {
            "titleBar.activeBackground" = "#000000";
            "titleBar.activeForeground" = "#00ff00";
            "titleBar.inactiveBackground" = "#0a0a0a";
            "activityBar.background" = "#000000";
            "activityBar.foreground" = "#00ff00";
            "activityBarBadge.background" = "#00ff00";
            "activityBarBadge.foreground" = "#000000";
            "statusBar.background" = "#000000";
            "statusBar.foreground" = "#00ff00";
            "statusBar.debuggingBackground" = "#333333";
            "statusBar.noFolderBackground" = "#000000";
            "tab.activeBackground" = "#0a0a0a";
            "tab.activeBorderTop" = "#00ff00";
            "editor.background" = "#000000";
            "editor.foreground" = "#00ff00";
            "editor.selectionBackground" = "#00ff0033";
            "editor.selectionHighlightBackground" = "#00ff0022";
            "editorCursor.foreground" = "#00ff00";
            "editorLineNumber.activeForeground" = "#00ff00";
            "progressBar.background" = "#00ff00";
            "focusBorder" = "#00ff00";
            "inputOption.activeBorder" = "#00ff00";
            "button.background" = "#00ff00";
            "button.hoverBackground" = "#00cc00";
            "button.foreground" = "#000000";
            "list.activeSelectionBackground" = "#00ff0022";
            "list.hoverBackground" = "#00ff0011";
            "badge.background" = "#00ff00";
            "badge.foreground" = "#000000";
          };

          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Fira Code', monospace";
          "editor.fontSize" = 14;
          "editor.fontLigatures" = true;
          "editor.lineHeight" = 1.6;

          "editor.smoothScrolling" = true;
          "editor.cursorBlinking" = "smooth";
          "editor.cursorSmoothCaretAnimation" = "on";
          "editor.minimap.enabled" = false;
          "editor.renderWhitespace" = "selection";
          "editor.bracketPairColorization.enabled" = true;
          "editor.guides.bracketPairs" = "active";
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
          "editor.wordWrap" = "on";

          "window.titleBarStyle" = "custom";
          "window.menuBarVisibility" = "toggle";

          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
          "terminal.integrated.fontSize" = 13;

          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;

          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";

          "git.autofetch" = true;
          "git.confirmSync" = false;

          "telemetry.telemetryLevel" = "off";
        };
      };
    };

    home.packages = with pkgs; [
      nil
      nixpkgs-fmt
    ];
  };
}
