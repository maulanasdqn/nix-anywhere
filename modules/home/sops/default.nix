{ username, sops-nix, pkgs, secretsFile, ... }:
{
  home-manager.users.${username} = { config, ... }: {
    imports = [
      sops-nix.homeManagerModules.sops
    ];

    home.packages = with pkgs; [
      sops
      age
    ];

    sops = {
      age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";

      defaultSopsFile = secretsFile;

      secrets = {
        github_token = { };
        openai_api_key = { };
        anthropic_api_key = { };
        database_password = { };
        ssh_private_key = {
          path = "/Users/${username}/.ssh/id_ed25519";
          mode = "0600";
        };
      };
    };
  };
}
