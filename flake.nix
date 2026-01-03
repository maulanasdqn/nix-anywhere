{
  description = "nix-anywhere: unified Nix configuration for NixOS + macOS";

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

    # Disko for declarative disk partitioning (nixos-anywhere)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      disko,
      ...
    }:
    let
      # Supported systems
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper to generate attrs for all systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Config
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

      # NixOS workstation args
      nixosSpecialArgs = {
        inherit username nixvim enableTilingWM sshKeys;
      };

      # NixOS VPS/server args (no Laravel on server)
      vpsSpecialArgs = {
        inherit username nixvim sshKeys;
        enableLaravel = false;
      };

      # Check if system is darwin
      isDarwin = system: builtins.elem system [ "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      # macOS (nix-darwin) configuration
      darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
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

      # NixOS workstation configuration
      nixosConfigurations.${nixosHostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = nixosSpecialArgs;
        modules = [
          ./hosts/workstation
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = nixosSpecialArgs;
              backupFileExtension = "backup";
            };
          }
          ./modules/home/nixos.nix
        ];
      };

      # NixOS VPS - Hostinger (for nixos-anywhere deployment)
      nixosConfigurations.hostinger = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = vpsSpecialArgs;
        modules = [
          disko.nixosModules.disko
          ./hosts/vps/hostinger
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = vpsSpecialArgs;
              backupFileExtension = "backup";
            };
          }
          ./modules/home/nixos-server.nix
        ];
      };

      # NixOS VPS - DigitalOcean (for nixos-anywhere deployment)
      nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = vpsSpecialArgs;
        modules = [
          disko.nixosModules.disko
          ./hosts/vps/digitalocean
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = vpsSpecialArgs;
              backupFileExtension = "backup";
            };
          }
          ./modules/home/nixos-server.nix
        ];
      };

      # Dev shells for all supported systems
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              (writeShellApplication {
                name = "rebuild";
                runtimeInputs =
                  if isDarwin system
                  then [ nix-darwin.packages.${system}.darwin-rebuild ]
                  else [ ];
                text =
                  if isDarwin system
                  then ''
                    echo "Rebuilding nix-darwin configuration..."
                    sudo darwin-rebuild switch --flake .
                    echo "Done!"
                  ''
                  else ''
                    echo "Rebuilding NixOS configuration..."
                    sudo nixos-rebuild switch --flake .
                    echo "Done!"
                  '';
              })
              nixfmt-rfc-style
            ];
          };
        }
      );

      # Formatter for all systems
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
