{ enableLaravel, lib, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    brews = lib.optionals enableLaravel [
      "mysql"
      "postgresql@16"
      "redis"
    ];

    casks = [
      "google-chrome"
      "microsoft-edge"
      "ghostty"
      "postman"
      "discord"
      "raycast"
      "shottr"
      "figma"
      "inkscape"
    ];
  };
}
