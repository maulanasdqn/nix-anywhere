{ username, pkgs, ... }:
{
  home-manager.users.${username}.programs.nixvim = {
    extraPackages = with pkgs; [
      # PHP
      phpactor
      php83Packages.php-cs-fixer
      php83Packages.phpstan

      # TypeScript/JavaScript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.eslint

      # Astro
      nodePackages."@astrojs/language-server"

      # Rust
      rust-analyzer
      clippy
    ];

    plugins = {
      lsp = {
        enable = true;
        servers = {
          # Lua
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                workspace.checkThirdParty = false;
                telemetry.enable = false;
                diagnostics.globals = [ "vim" ];
              };
            };
          };

          # Nix
          nil_ls.enable = true;

          # PHP/Laravel
          phpactor = {
            enable = true;
            settings = {
              language_server_phpstan.enabled = true;
              language_server_psalm.enabled = false;
            };
          };

          # TypeScript/JavaScript/React
          ts_ls = {
            enable = true;
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                };
              };
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                };
              };
            };
          };

          eslint.enable = true;

          # Rust - disabled, using rustaceanvim instead
          # rust_analyzer.enable = true;

          # TOML (Cargo.toml, etc.)
          taplo.enable = true;

          # CSS/Tailwind
          tailwindcss = {
            enable = true;
            filetypes = [
              "html"
              "css"
              "scss"
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
              "astro"
            ];
          };
          cssls.enable = true;

          # HTML
          html.enable = true;
          emmet_ls = {
            enable = true;
            filetypes = [
              "html"
              "css"
              "scss"
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
              "php"
              "blade"
              "astro"
            ];
          };

          # JSON
          jsonls.enable = true;

          # Astro
          astro = {
            enable = true;
            settings = {
              typescript = {
                tsdk = "./node_modules/typescript/lib";
              };
            };
          };
        };

        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "gr" = "references";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
          };
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };

      lspsaga = {
        enable = true;
        settings = {
          lightbulb.enable = false;
          symbol_in_winbar.enable = true;
          ui = {
            border = "rounded";
            code_action = "💡";
          };
        };
      };

      # Rust tools
      rustaceanvim = {
        enable = true;
        settings = {
          server = {
            on_attach = "__lspOnAttach";
            settings = {
              rust-analyzer = {
                checkOnSave.command = "clippy";
                cargo.allFeatures = true;
              };
            };
          };
        };
      };
    };
  };
}
