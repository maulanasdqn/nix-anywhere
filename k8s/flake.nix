{
  description = "Nix-native Kubernetes manifests using easykubenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    easykubenix = {
      url = "github:lillecarl/easykubenix";
    };

    # Application flakes no longer needed here — frontends use hostPath
    # symlinks managed by NixOS, backends run as systemd services.
  };

  outputs =
    {
      self,
      nixpkgs,
      easykubenix,
      ...
    }:
    let
      # Systems we can build manifests FROM
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Create k8s manifests generator for any build system
      mkK8s =
        buildSystem:
        let
          # Use build system for manifest generation (YAML is just text)
          pkgs = nixpkgs.legacyPackages.${buildSystem};
        in
        easykubenix.lib.easykubenix {
          inherit pkgs;
          modules = [
            ./modules/common.nix
            ./modules/apps/kilat-app.nix
            # Add more modules as we migrate services
          ];
          specialArgs = { };
        };
    in
    {
      # Output packages for each supported build system
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          k8s = mkK8s system;
        in
        {
          default = k8s.manifestYAMLFile;
          manifests = k8s.manifestAttrs;
          manifestYAML = k8s.manifestYAMLFile;
          manifestJSON = k8s.manifestJSONFile;
        }
      );

      # Apps for each supported system
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          k8s = mkK8s system;
        in
        {
          # Generate and apply manifests
          deploy = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "deploy" ''
                set -e
                echo "Generating and applying Kubernetes manifests..."
                ${pkgs.kubectl}/bin/kubectl apply -f ${k8s.manifestYAMLFile}
                echo "Manifests applied successfully!"
              ''
            );
          };

          # Validate manifests
          validate = {
            type = "app";
            program = toString k8s.validationScript;
          };

          # Show generated manifests
          show = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "show" ''
                cat ${k8s.manifestYAMLFile}
              ''
            );
          };
        }
      );
    };
}
