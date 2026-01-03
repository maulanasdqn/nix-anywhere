{
  # Darwin (macOS)
  darwinUsername = "ms";
  darwinHostname = "mrscraper";
  darwinEnableTilingWM = true;

  # Workstation (NixOS desktop)
  workstationUsername = "ms";
  workstationHostname = "workstation";
  workstationEnableTilingWM = true;

  # VPS - Hostinger
  vpsHostingerUsername = "ms";
  vpsHostingerHostname = "msdqn";
  vpsHostingerIP = "72.62.125.38";
  vpsHostingerGateway = "72.62.125.254";

  # VPS - DigitalOcean
  vpsDigitalOceanUsername = "ms";
  vpsDigitalOceanHostname = "droplet";

  # Development tools
  enableLaravel = true;
  enableRust = true;
  enableVolta = true;

  # SSH keys (shared across all systems)
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer"
  ];
}
