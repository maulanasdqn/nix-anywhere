{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./system
    ./security
    ./packages
    ./defaults
    ./fonts
    ./homebrew
    ./yabai
    ./skhd
    ./sketchybar
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
