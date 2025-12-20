{ username, enableLaravel, lib, ... }:
{
  home-manager.users.${username}.programs.zsh.shellAliases = {
    # General
    c = "clear";
    v = "nvim";
    t = "tmux";
    cl = "claude";
    build-system = "sudo nix run nix-darwin -- switch --flake ~/.config/nix";

    # Devenv project init
    init-laravel = "cp ~/.config/nix/templates/laravel/{flake.nix,.envrc} . && direnv allow";
    init-nodejs = "cp ~/.config/nix/templates/nodejs/{flake.nix,.envrc} . && direnv allow";
    init-rust = "cp ~/.config/nix/templates/rust/{flake.nix,.envrc} . && direnv allow";

    # File listing
    ls = "eza --icons";
    ll = "eza -la --icons";
    la = "eza -a --icons";
    lt = "eza --tree --icons";
    l = "eza -l --icons";
    cat = "bat";

    # Docker
    dc = "docker-compose";
    dps = "docker ps";
    dex = "docker exec -it";

    # Git
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gco = "git checkout";
    gcb = "git checkout -b";
  } // lib.optionalAttrs enableLaravel {
    # Laravel/PHP (only when enabled)
    pa = "php artisan";
    pas = "php artisan serve";
    pam = "php artisan migrate";
    pamfs = "php artisan migrate:fresh --seed";
    ci = "composer install";
    cu = "composer update";
  };
}
