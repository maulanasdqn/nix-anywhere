{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        fenix = inputs.fenix.packages.${system};
      in {
        devenv.shells.default = {
          name = "rust";

          # Rust toolchain - options: stable, beta, nightly
          languages.rust = {
            enable = true;
            channel = "stable";  # or "beta" or "nightly"
            components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
          };

          # Packages
          packages = with pkgs; [
            cargo-watch
            cargo-edit
            cargo-expand
            cargo-audit
            cargo-outdated
            rust-analyzer
            pkg-config
            openssl
          ];

          # Environment variables
          env = {
            RUST_BACKTRACE = "1";
            RUST_LOG = "debug";
          };

          # Scripts
          scripts.dev.exec = "cargo watch -x run";
          scripts.build.exec = "cargo build --release";
          scripts.test.exec = "cargo test";
          scripts.check.exec = "cargo clippy && cargo fmt --check";
          scripts.doc.exec = "cargo doc --open";

          enterShell = ''
            echo "🦀 Rust Development Environment"
            echo "Rust: $(rustc --version)"
            echo "Cargo: $(cargo --version)"
            echo ""
            echo "Commands: dev, build, test, check, doc"
          '';
        };
      };
    };
}
