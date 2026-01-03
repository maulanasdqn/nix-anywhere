# DigitalOcean KVM hardware configuration
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    # KVM virtio modules
    initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net" "ahci" "xhci_pci" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ "virtio_blk" "virtio_pci" "virtio_net" ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    # Hybrid BIOS/EFI boot for DigitalOcean
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = lib.mkForce false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
