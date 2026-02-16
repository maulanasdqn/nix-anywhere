{
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    isNormalUser = true;
    description = "Akhyar Azamta";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
      "dialout"
      "plugdev"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
