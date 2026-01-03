{ username, ... }:
{
  home-manager.users.${username}.home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 14

    window-padding-x = 10
    window-padding-y = 10
    window-decoration = true
    macos-titlebar-style = hidden
    background-opacity = 0.9
    background-blur-radius = 50

    clipboard-read = allow
    clipboard-write = allow
    clipboard-paste-protection = false

    background = 191724
    foreground = e0def4

    cursor-color = 524f67
    cursor-text = e0def4

    selection-background = 403d52
    selection-foreground = e0def4

    palette = 0=#26233a
    palette = 1=#eb6f92
    palette = 2=#31748f
    palette = 3=#f6c177
    palette = 4=#9ccfd8
    palette = 5=#c4a7e7
    palette = 6=#ebbcba
    palette = 7=#e0def4

    palette = 8=#6e6a86
    palette = 9=#eb6f92
    palette = 10=#31748f
    palette = 11=#f6c177
    palette = 12=#9ccfd8
    palette = 13=#c4a7e7
    palette = 14=#ebbcba
    palette = 15=#e0def4
  '';
}
