{ enableLaravel, lib, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    # Formulae (CLI tools & services)
    brews = lib.optionals enableLaravel [
      "mysql"
      "postgresql@16"
      "redis"
    ];

    # GUI Apps
    casks = [
      "microsoft-edge"
      "ghostty"
      "postman"
      "discord"
      "raycast"
      "shottr"
    ];
  };
}
