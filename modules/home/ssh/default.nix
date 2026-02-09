{ username, sshKeys, lib, ... }:
{
  home-manager.users.${username} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          extraOptions = {
            AddKeysToAgent = "yes";
          };
        };
      };
    };

    home.file.".ssh/authorized_keys" = lib.mkIf (sshKeys != []) {
      text = lib.concatStringsSep "\n" sshKeys + "\n";
    };
  };
}
