{
  config,
  lib,
  pkgs,
  username,
  enableTilingWM,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../profiles/workstation.nix
  ];
}

