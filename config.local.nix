{
  darwinUsername = "ms";
  darwinHostname = "mrscraper";
  darwinEnableTilingWM = true;

  workstationUsername = "ms";
  workstationHostname = "workstation";
  workstationEnableTilingWM = true;

  vpsHostingerUsername = "ms";
  vpsHostingerHostname = "msdqn";
  vpsHostingerIP = "72.62.125.38";
  vpsHostingerGateway = "72.62.125.254";

  acmeEmail = "maulanasdqn@gmail.com";

  vpsDigitalOceanUsername = "ms";
  vpsDigitalOceanHostname = "droplet";

  enableLaravel = false; # Disabled due to nixpkgs composer bug
  enableRust = true;
  enableVolta = true;

  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdLKnxrQl735W+ANR4dnWTrNEMmrIzv7TioI0teJmMZ ms@computer"
  ];
}
