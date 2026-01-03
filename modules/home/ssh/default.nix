{ username, sshKeys, lib, ... }:
{
  home-manager.users.${username} = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          extraOptions = {
            AddKeysToAgent = "yes";
            IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
          };
        };
      };
    };

    home.file.".ssh/authorized_keys" = lib.mkIf (sshKeys != []) {
      text = lib.concatStringsSep "\n" sshKeys + "\n";
    };
  };
}
