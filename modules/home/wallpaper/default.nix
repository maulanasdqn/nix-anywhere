{ username, pkgs, config, ... }:
let
  wallpaper = pkgs.nixos-artwork.wallpapers.catppuccin-mocha;
  wallpaperPath = "${wallpaper}/share/backgrounds/nixos/nix-wallpaper-catppuccin-mocha.png";
in
{
  home-manager.users.${username} = { lib, ... }: {
    home.packages = [ wallpaper ];

    home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${wallpaperPath}" ]; then
        /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaperPath}"'
      fi
    '';
  };
}
