{ username, pkgs, config, ... }:
let
  # Available wallpapers from nixos-artwork:
  # binary-black, binary-blue, binary-red, binary-white
  # catppuccin-frappe, catppuccin-latte, catppuccin-macchiato, catppuccin-mocha
  # gear, moonscape, recursive, waterfall, watersplash
  # nineish, nineish-dark-gray, nineish-solarized-dark, nineish-solarized-light
  # simple-blue, simple-dark-gray, simple-light-gray, simple-red
  # dracula, gradient-grey, mosaic-blue, stripes, stripes-logo

  wallpaper = pkgs.nixos-artwork.wallpapers.catppuccin-mocha;
  wallpaperPath = "${wallpaper}/share/backgrounds/nixos/nix-wallpaper-catppuccin-mocha.png";
in
{
  home-manager.users.${username} = { lib, ... }: {
    home.packages = [ wallpaper ];

    # Set wallpaper on activation
    home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${wallpaperPath}" ]; then
        /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaperPath}"'
      fi
    '';
  };
}
