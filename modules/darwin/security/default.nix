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

    rm -f /usr/local/bin/yabai
    cp ${pkgs.yabai}/bin/yabai /usr/local/bin/yabai
    chmod +x /usr/local/bin/yabai
    rm -f /usr/local/bin/skhd
    cp ${pkgs.skhd}/bin/skhd /usr/local/bin/skhd
    chmod +x /usr/local/bin/skhd

    echo "Copied yabai and skhd binaries to /usr/local/bin"
  '';
}
