{
  description = "Arduino development environment (PlatformIO)";

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
      in
      let
        # PlatformIO convenience scripts
        pio-build = pkgs.writeShellScriptBin "build" "platformio run \"$@\"";
        pio-upload = pkgs.writeShellScriptBin "upload" "platformio run --target upload \"$@\"";
        pio-monitor = pkgs.writeShellScriptBin "monitor" "platformio device monitor \"$@\"";
        pio-upload-monitor = pkgs.writeShellScriptBin "upload-monitor" "platformio run --target upload && platformio device monitor \"$@\"";
        pio-clean = pkgs.writeShellScriptBin "clean" "platformio run --target clean \"$@\"";
        pio-fullclean = pkgs.writeShellScriptBin "fullclean" "platformio run --target fullclean \"$@\"";
        pio-devices = pkgs.writeShellScriptBin "devices" "platformio device list \"$@\"";
        pio-progsize = pkgs.writeShellScriptBin "progsize" "platformio run --target size \"$@\"";
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            platformio-core
            avrdude
            python3
            gcc
            gnumake
            cmake
            pkg-config
            libusb1
            zlib

            # PlatformIO shortcut scripts
            pio-build
            pio-upload
            pio-monitor
            pio-upload-monitor
            pio-clean
            pio-fullclean
            pio-devices
            pio-progsize
          ];

          shellHook = ''
            echo "Arduino Development Environment"
            echo ""
            echo "Commands:"
            echo "  build          - Compile project"
            echo "  upload         - Upload firmware"
            echo "  monitor        - Serial monitor"
            echo "  upload-monitor - Upload + monitor"
            echo "  clean          - Clean build files"
            echo "  fullclean      - Full clean"
            echo "  devices        - List connected devices"
            echo "  progsize       - Show program size"
            echo ""

            # Fix shebangs in PlatformIO's downloaded packages
            # PlatformIO bundles binaries with #!/bin/bash which doesn't exist on NixOS
            PLATFORMIO_PACKAGES="$HOME/.platformio/packages"
            if [ -d "$PLATFORMIO_PACKAGES" ]; then
              find "$PLATFORMIO_PACKAGES" -maxdepth 3 -type f -executable 2>/dev/null | while read f; do
                if head -c 2 "$f" 2>/dev/null | grep -q '#!'; then
                  first_line=$(head -1 "$f" 2>/dev/null)
                  if echo "$first_line" | grep -q '/bin/bash'; then
                    sed -i "1s|#!/bin/bash|#!$(command -v bash)|" "$f" 2>/dev/null || true
                  elif echo "$first_line" | grep -q '/usr/bin/env'; then
                    sed -i "1s|/usr/bin/env|$(command -v env)|" "$f" 2>/dev/null || true
                  fi
                fi
              done
            fi
          '';
        };
      }
    );
}
