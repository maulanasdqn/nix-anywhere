{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      colima
      docker-client
      docker-compose
    ];

    programs.zsh.shellAliases = {
      dc = "docker compose";
      dps = "docker ps";
      dpsa = "docker ps -a";
      di = "docker images";
      dex = "docker exec -it";
      dlog = "docker logs -f";
    };
  };
}
