#!/usr/bin/env bash
set -euo pipefail

# NixOS-infect one-shot deployment script for Hostinger VPS

# Write the NixOS configuration
mkdir -p /etc/nixos
cat > /etc/nixos/configuration.nix << 'NIXCONFIG'
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Boot - simple BIOS GRUB
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net" "ahci" "sd_mod" ];

  # Filesystem - will be auto-detected, but define root
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # Networking
  networking.hostName = "vps";
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # User
  users.users.ms = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer"
  ];

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable zsh and basic packages
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    vim git curl wget htop tmux
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # Nginx
  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      default = true;
      locations."/" = {
        return = "200 'NixOS VPS is running!'";
        extraConfig = "add_header Content-Type text/plain;";
      };
    };
  };

  system.stateVersion = "24.11";
}
NIXCONFIG

echo "Configuration written to /etc/nixos/configuration.nix"
echo "Starting nixos-infect..."

# Run nixos-infect
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.11 bash -x
