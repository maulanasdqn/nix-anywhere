{
  config,
  pkgs,
  lib,
  username,
  enableTilingWM,
  ...
}:
{
  imports =
    [
      ./system
      ./security
      ./packages
      ./defaults
      ./fonts
      ./homebrew
    ]
    ++ lib.optionals enableTilingWM [
      ./yabai
      ./skhd
      ./sketchybar
    ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
