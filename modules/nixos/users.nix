{
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    isNormalUser = true;
    description = "Maulana Sodiqin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
