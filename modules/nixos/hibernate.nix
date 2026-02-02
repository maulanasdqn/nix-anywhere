{ config, lib, ... }:

let
  # Ambil swap device pertama secara otomatis dari swapDevices
  swapDevices = config.swapDevices;
  hasSwap = swapDevices != [ ];
  firstSwap = if hasSwap then (builtins.head swapDevices) else null;
  
  # Resume device bisa berupa device path atau UUID
  resumeDevice = if firstSwap != null then firstSwap.device else null;
in
{
  config = lib.mkIf (resumeDevice != null) {
    # Set resume device otomatis dari swap partition pertama
    boot.resumeDevice = resumeDevice;

    # Konfigurasi systemd sleep
    systemd.sleep.extraConfig = ''
      AllowHibernation=yes
      AllowSuspendThenHibernate=yes
      HibernateDelaySec=1h
    '';
  };
}
