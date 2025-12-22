{
  username,
  pkgs,
  lib,
  enableTilingWM,
  ...
}:
{
  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Passwordless sudo
  environment.etc."sudoers.d/10-nix-darwin".text = ''
    ${username} ALL=(ALL) NOPASSWD: ALL
  '';

  # Create stable symlinks for yabai and skhd so accessibility permissions persist
  # The nix store paths change on every rebuild, but these symlinks stay constant
  system.activationScripts.postActivation.text = lib.mkIf enableTilingWM ''
    # Create /usr/local/bin if it doesn't exist
    mkdir -p /usr/local/bin

    # Create stable symlinks for yabai and skhd
    # These paths don't change, so accessibility permissions persist
    ln -sf ${pkgs.yabai}/bin/yabai /usr/local/bin/yabai
    ln -sf ${pkgs.skhd}/bin/skhd /usr/local/bin/skhd

    echo "Created stable symlinks for yabai and skhd in /usr/local/bin"
  '';
}
