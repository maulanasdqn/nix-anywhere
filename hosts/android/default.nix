{ config, lib, pkgs, ... }:

{
  environment.packages = with pkgs; [
    git
    curl
    wget
    jq
    ripgrep
    fd
    fzf
    bat
    htop
    tmux
    openssh
    zsh
    starship
  ];

  environment.etcBackupExtension = ".bak";

  # Under proot, tcgetattr() on a PTY fd returns EACCES instead of ENOTTY.
  # nix 2.18 calls tcgetattr(STDIN_FILENO) before building user-environment.drv
  # and throws "getting pseudoterminal attributes: Permission denied" on EACCES.
  #
  # Fix: inject a nix-env wrapper into PATH that redirects stdin/stdout away from
  # the terminal before calling real nix-env. With stdin/stdout as /dev/null,
  # tcgetattr returns ENOTTY (expected) instead of EACCES, so nix proceeds normally.
  build.activationBefore.fixNixEnvPty = ''
    mkdir -p /tmp/nix-env-compat
    cat > /tmp/nix-env-compat/nix-env << 'EOF'
#!/bin/sh
exec ${config.nix.package}/bin/nix-env "$@" </dev/null 1>/dev/null
EOF
    chmod +x /tmp/nix-env-compat/nix-env
    export PATH="/tmp/nix-env-compat:$PATH"
  '';

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "Asia/Jakarta";

  system.stateVersion = "24.05";
}
