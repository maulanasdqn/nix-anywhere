{
  description = "Laravel Development Environment";

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
          name = "laravel";

          # PHP version - change as needed: php81, php82, php83, php84
          languages.php = {
            enable = true;
            package = pkgs.php83;
            extensions = [ "mbstring" "openssl" "pdo" "pdo_mysql" "pdo_pgsql" "tokenizer" "xml" "ctype" "json" "bcmath" "curl" "gd" "zip" "redis" ];
          };

          # Node.js for frontend assets
          languages.javascript = {
            enable = true;
            package = pkgs.nodejs_22;
          };

          # Packages
          packages = with pkgs; [
            php83Packages.composer
            php83Packages.php-cs-fixer
            nodePackages.npm
            mysql-client
            redis
          ];

          # Environment variables
          env = {
            APP_ENV = "local";
          };

          # Services (optional - uncomment if needed)
          # services.mysql.enable = true;
          # services.redis.enable = true;

          # Scripts
          scripts.serve.exec = "php artisan serve";
          scripts.migrate.exec = "php artisan migrate";
          scripts.fresh.exec = "php artisan migrate:fresh --seed";
          scripts.test.exec = "php artisan test";

          enterShell = ''
            echo "🚀 Laravel Development Environment"
            echo "PHP: $(php -v | head -1)"
            echo "Composer: $(composer --version)"
            echo "Node: $(node --version)"
            echo ""
            echo "Commands: serve, migrate, fresh, test"
          '';
        };
      };
    };
}
