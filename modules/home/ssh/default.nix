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
        "jl" = {
          hostname = "192.168.201.28";
          user = "mrscrapersupport";
          port = 22;
        };
      };
    };

    home.file.".ssh/authorized_keys" = lib.mkIf (sshKeys != []) {
      text = lib.concatStringsSep "\n" sshKeys + "\n";
    };
  };
}
