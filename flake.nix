{
  description = "ms's unified Nix configuration (NixOS + nix-darwin)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      determinate,
      nixvim,
      sops-nix,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    let
      defaultConfig = import ./config.nix;
      localConfigPath = ./config.local.nix;
      config =
        if builtins.pathExists localConfigPath then
          defaultConfig // (import localConfigPath)
        else
          defaultConfig;

      username = config.username;
      darwinHostname = config.darwinHostname or config.hostname;
      nixosHostname = config.nixosHostname or "nixos";
      enableLaravel = config.enableLaravel;
      enableTilingWM = config.enableTilingWM;
      sshKeys = config.sshKeys;
      secretsFile = ./secrets/secrets.yaml;

      # Darwin-specific
      darwinSystem = "aarch64-darwin";
      darwinSpecialArgs = {
        inherit
          username
          nixvim
          enableLaravel
          enableTilingWM
          sshKeys
          sops-nix
          secretsFile
          ;
      };

      # NixOS-specific
      nixosSystem = "x86_64-linux";
      nixosSpecialArgs = {
        inherit username nixvim;
      };
    in
    {
      # macOS (nix-darwin) configuration
      darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = darwinSpecialArgs;
        modules = [
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
              mutableTaps = false;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
            };
          }
          ./modules/nix.nix
          ./modules/darwin
          ./modules/home/darwin.nix
        ];
      };

      # NixOS configuration
      nixosConfigurations.${nixosHostname} = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
        specialArgs = nixosSpecialArgs;
        modules = [
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = nixosSpecialArgs;
              backupFileExtension = "backup";
              sharedModules = [
                nixvim.homeModules.nixvim
              ];
            };
          }
          ./modules/home/nixos.nix
        ];
      };

      # Dev shells for both systems
      devShells.${darwinSystem}.default =
        let
          pkgs = import nixpkgs { system = darwinSystem; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "rebuild";
              runtimeInputs = [ nix-darwin.packages.${darwinSystem}.darwin-rebuild ];
              text = ''
                echo "Rebuilding nix-darwin configuration..."
                sudo darwin-rebuild switch --flake .
                echo "Done!"
              '';
            })
            self.formatter.${darwinSystem}
          ];
        };

      devShells.${nixosSystem}.default =
        let
          pkgs = import nixpkgs { system = nixosSystem; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "rebuild";
              text = ''
                echo "Rebuilding NixOS configuration..."
                sudo nixos-rebuild switch --flake .
                echo "Done!"
              '';
            })
            self.formatter.${nixosSystem}
          ];
        };

      formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt-rfc-style;
      formatter.${nixosSystem} = nixpkgs.legacyPackages.${nixosSystem}.nixfmt-rfc-style;
    };
}
