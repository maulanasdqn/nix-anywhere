# DigitalOcean Droplet configuration
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
    ../../../profiles/server.nix
  ];

  networking.hostName = "droplet"; # Change this per droplet

  # DigitalOcean uses DHCP
  networking.useDHCP = true;

  # Ensure SSH keys are configured
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
  users.users.${username}.openssh.authorizedKeys.keys = sshKeys;
}
