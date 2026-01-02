# VPS host configuration
{
  config,
  lib,
  pkgs,
  username,
  sshKeys,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../profiles/server.nix
  ];

  networking.hostName = "vps";

  # Ensure SSH keys are configured for nixos-anywhere
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
  users.users.${username}.openssh.authorizedKeys.keys = sshKeys;
}
