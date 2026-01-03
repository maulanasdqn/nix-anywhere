{
  pkgs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg

      comfortaa
      quicksand
      comic-neue

      inter
      roboto
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Quicksand" "Comfortaa" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
