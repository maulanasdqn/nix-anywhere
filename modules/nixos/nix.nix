{
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      # Enable flakes and new nix command
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Automatic garbage collection
      auto-optimise-store = true;

      # Trusted users
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Substituters for faster builds
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
