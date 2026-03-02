{ pkgs, clan-core, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    qemu
    clan-core.packages.aarch64-darwin.clan-cli
  ];
}
