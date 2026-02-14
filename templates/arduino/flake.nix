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
          ];

          shellHook = ''
            echo "Arduino Development Environment"
            echo "Commands: platformio, pio"
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
              echo "Patched PlatformIO package shebangs for NixOS compatibility."
            fi
          '';
        };
      }
    );
}
