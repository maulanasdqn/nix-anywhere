{
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Kernel parameters for better performance
    kernelParams = [
      "quiet"
      "splash"
    ];

    # Clean /tmp on boot
    tmp.cleanOnBoot = true;
  };
}
