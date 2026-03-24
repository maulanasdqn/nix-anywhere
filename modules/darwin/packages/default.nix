{
  pkgs,
  clan-core,
  claude-code,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    qemu
    gh
    cargo
    rustc
    nixos-rebuild
    android-tools
    (callPackage ../../../pkgs/rtk { })
    clan-core.packages.aarch64-darwin.clan-cli
    claude-code.packages.aarch64-darwin.claude-code
  ];
}
