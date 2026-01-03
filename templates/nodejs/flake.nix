{
  description = "Node.js Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default = {
          name = "nodejs";

          languages.javascript = {
            enable = true;
            package = pkgs.nodejs_22;
          };

          languages.typescript.enable = true;

          packages = with pkgs; [
            nodePackages.npm
            nodePackages.pnpm
            nodePackages.yarn
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.eslint
            nodePackages.prettier
            bun
            deno
          ];

          env = {
            NODE_ENV = "development";
          };

          scripts.dev.exec = "npm run dev";
          scripts.build.exec = "npm run build";
          scripts.test.exec = "npm test";
          scripts.lint.exec = "npm run lint";

          enterShell = ''
            echo "Node.js Development Environment"
            echo "Node: $(node --version)"
            echo "NPM: $(npm --version)"
            echo "PNPM: $(pnpm --version)"
            echo "Bun: $(bun --version)"
            echo ""
            echo "Commands: dev, build, test, lint"
          '';
        };
      };
    };
}
