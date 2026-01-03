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
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons

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
          "workbench.colorTheme" = "Catppuccin Latte";
          "workbench.iconTheme" = "catppuccin-latte";
          "catppuccin.accentColor" = "pink";

          "workbench.colorCustomizations" = {
            "[Catppuccin Latte]" = {
              "titleBar.activeBackground" = "#ff69b4";
              "titleBar.activeForeground" = "#ffffff";
              "titleBar.inactiveBackground" = "#ffb6c1";
              "activityBar.background" = "#fff0f5";
              "activityBar.foreground" = "#ff69b4";
              "activityBarBadge.background" = "#ff69b4";
              "activityBarBadge.foreground" = "#ffffff";
              "statusBar.background" = "#ff69b4";
              "statusBar.foreground" = "#ffffff";
              "statusBar.debuggingBackground" = "#ff85a2";
              "statusBar.noFolderBackground" = "#ffb6c1";
              "tab.activeBackground" = "#fff5f7";
              "tab.activeBorderTop" = "#ff69b4";
              "editor.selectionBackground" = "#ffc0cb80";
              "editor.selectionHighlightBackground" = "#ffb6c140";
              "editorCursor.foreground" = "#ff69b4";
              "editorLineNumber.activeForeground" = "#ff69b4";
              "progressBar.background" = "#ff69b4";
              "focusBorder" = "#ff69b4";
              "inputOption.activeBorder" = "#ff69b4";
              "button.background" = "#ff69b4";
              "button.hoverBackground" = "#ff85a2";
              "list.activeSelectionBackground" = "#ffc0cb60";
              "list.hoverBackground" = "#fff0f5";
              "badge.background" = "#ff69b4";
              "badge.foreground" = "#ffffff";
            };
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
