{
  description = "ms's nix-darwin configuration";

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
      hostname = config.hostname;
      enableLaravel = config.enableLaravel;
      enableTilingWM = config.enableTilingWM;
      sshKeys = config.sshKeys;
      system = "aarch64-darwin";
      secretsFile = ./secrets/secrets.yaml;
      specialArgs = {
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
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          ./modules/nix.nix
          ./modules/darwin
          ./modules/home
        ];
      };

      devShells.${system}.default =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "rebuild";
              runtimeInputs = [ nix-darwin.packages.${system}.darwin-rebuild ];
              text = ''
                echo "Rebuilding nix-darwin configuration..."
                sudo darwin-rebuild switch --flake .
                echo "Done!"
              '';
            })
            self.formatter.${system}
          ];
        };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
