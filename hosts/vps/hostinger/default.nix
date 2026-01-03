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
    ../../../profiles/server.nix
  ];

  networking.hostName = "msdqn";

  # Static IP configuration for Hostinger VPS
  networking.useDHCP = false;
  networking.interfaces.ens18 = {
    ipv4.addresses = [{
      address = "72.62.125.38";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "72.62.125.254";
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Temporary root password for console access (nixos123)
  users.users.root.hashedPassword = "$6$wYqKxykN.5A6PenN$5TdXvY4r1q4GSKfR3pTJbpyWOGnqcS4lt/OsNE3E4TNQLK6r.Nso/bvCwkg1Ta/N2eXOBO1WyYYR/QZqYRcTf1";

  # Allow password auth temporarily for debugging
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

  # Ensure SSH keys are configured for nixos-anywhere
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
  users.users.${username}.openssh.authorizedKeys.keys = sshKeys;
}
