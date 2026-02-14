{
  description = "Arduino development environment (PlatformIO FHS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Wrap PlatformIO in an FHS environment to allow it to run binaries
        # that expect standard paths like /bin/bash (e.g. avrdude)
        fhs = pkgs.buildFHSEnv {
          name = "platformio-shell";
          targetPkgs = pkgs: (with pkgs; [
            platformio
            avrdude
            python3
            gcc
            glibc
            pkg-config
            libusb1
            zlib
            systemd
            gnumake
            cmake
            
            # Common dependencies for platformio packages
            ncurses5
            ncurses
          ]);
          
          # Allow running the shell
          runScript = "zsh";

          # Set environment variables if needed
          profile = ''
            export PLATFORMIO_CORE_DIR=$PWD/.platformio
          '';
        };
      in
      {
        devShells.default = fhs.env;
      }
    );
}
