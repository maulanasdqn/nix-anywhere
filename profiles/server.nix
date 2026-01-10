{
  lib,
  pkgs,
  username,
  acmeEmail,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://msdqn.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "msdqn.cachix.org-1:I5z8egjNf2iKYLwLGF2REfpELlFoUdaSLsh7dQk1a+o="
    ];
  };

  time.timeZone = lib.mkForce "UTC";

  users.users.${username}.extraGroups = [
    "wheel"
    "docker"
  ];

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [ ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    appendHttpConfig = ''
      ssl_ecdh_curve X25519:secp384r1:prime256v1;
      ssl_conf_command Groups X25519:secp384r1:prime256v1;
    '';

    virtualHosts."_" = {
      default = true;
      locations."/" = {
        return = "200 'NixOS VPS is running!'";
        extraConfig = ''
          add_header Content-Type text/plain;
        '';
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = acmeEmail;
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "04:00";
  };

  services.logrotate.enable = true;
  services.avahi.enable = false;
  services.printing.enable = false;

  environment.systemPackages = with pkgs; [
    htop
    iotop
    ncdu
    bottom
    tmux
    ripgrep
    fd
    jq
    yq
    docker-compose
    lazydocker
    curl
    wget
    httpie
    git
    nodejs_22
    nodePackages.npm
    neofetch
    cachix
  ];

}
