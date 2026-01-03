# VPS hardware configuration - Hostinger KVM BIOS boot
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # KVM guest support - force modules into initrd
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "ahci"
    "sd_mod"
    "ext4"
  ];
  boot.initrd.kernelModules = [ "virtio_blk" "virtio_pci" "virtio_net" "ext4" ];
  boot.kernelModules = [ "virtio_net" ];
  boot.extraModulePackages = [ ];

  # Use LTS kernel for better compatibility
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Console output - try multiple outputs
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200"
    "nomodeset"
  ];

  # GRUB for BIOS boot (override base.nix defaults)
  # Note: disko automatically adds device from EF02 partition
  boot.loader.grub.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
