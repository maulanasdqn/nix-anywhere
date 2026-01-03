{
  username,
  pkgs,
  lib,
  enableTilingWM,
  ...
}:
{
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.etc."sudoers.d/10-nix-darwin".text = ''
    ${username} ALL=(ALL) NOPASSWD: ALL
  '';

  system.activationScripts.postActivation.text = lib.mkIf enableTilingWM ''
    mkdir -p /usr/local/bin

    ln -sf ${pkgs.yabai}/bin/yabai /usr/local/bin/yabai
    ln -sf ${pkgs.skhd}/bin/skhd /usr/local/bin/skhd

    echo "Created stable symlinks for yabai and skhd in /usr/local/bin"
  '';
}
