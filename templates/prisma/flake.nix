{
  description = "Prisma + Node.js Development Environment";

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
          name = "prisma";

          languages.javascript = {
            enable = true;
            package = pkgs.nodejs_22;
          };

          languages.typescript.enable = true;

          packages = with pkgs; [
            nodePackages.npm
            nodePackages.pnpm
            nodePackages.prisma
            nodePackages.typescript
            nodePackages.typescript-language-server
            prisma-engines
            openssl
          ];

          env = {
            NODE_ENV = "development";
            PRISMA_MIGRATION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/migration-engine";
            PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
            PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
            PRISMA_INTROSPECTION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/introspection-engine";
            PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
          };

          scripts.dev.exec = "npm run dev";
          scripts.build.exec = "npm run build";
          scripts.generate.exec = "npx prisma generate";
          scripts.migrate.exec = "npx prisma migrate dev";
          scripts.studio.exec = "npx prisma studio";
          scripts.push.exec = "npx prisma db push";
          scripts.seed.exec = "npx prisma db seed";

          enterShell = ''
            echo "Prisma + Node.js Development Environment"
            echo "Node: $(node --version)"
            echo "NPM: $(npm --version)"
            echo "Prisma: $(npx prisma --version | head -1)"
            echo ""
            echo "Commands: dev, build, generate, migrate, studio, push, seed"
          '';
        };
      };
    };
}
