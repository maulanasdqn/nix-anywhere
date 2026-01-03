{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"
      "ahci"
      "sd_mod"
    ];
    initrd.kernelModules = [
      "virtio_blk"
      "virtio_pci"
      "virtio_net"
    ];
    kernelModules = [ "virtio_net" ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_6_6;
    loader.grub.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = lib.mkForce false;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
