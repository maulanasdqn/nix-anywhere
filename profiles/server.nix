# Server profile - Headless server with security hardening
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # Server-specific timezone (UTC for servers)
  time.timeZone = lib.mkForce "UTC";

  # Minimal user groups for server
  users.users.${username}.extraGroups = [
    "wheel"
    "docker"
  ];

  # Static networking (no NetworkManager)
  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = false;

    # Firewall - restrictive by default
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

  # Hardened SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password"; # Allow for nixos-anywhere initial deploy
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
    };
  };

  # Nginx web server
  services.nginx = {
    enable = true;

    # Recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Default virtual host
    virtualHosts."_" = {
      default = true;
      locations."/" = {
        return = "200 'NixOS VPS is running!'";
        extraConfig = ''
          add_header Content-Type text/plain;
        '';
      };
    };

    # Example: Reverse proxy for Docker containers
    # virtualHosts."app.example.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:3000";
    #     proxyWebsockets = true;
    #   };
    # };
  };

  # ACME (Let's Encrypt) for SSL certificates
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@example.com"; # Change this!
  };

  # Fail2ban for brute-force protection
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };

  # Kernel hardening
  boot.kernel.sysctl = {
    # Prevent IP spoofing
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Ignore ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;

    # Ignore broadcast pings
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };

  # Security limits
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

  # Docker for containers
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false; # Manual reboots for control
    dates = "04:00";
  };

  # Log rotation
  services.logrotate.enable = true;

  # Disable unnecessary services
  services.avahi.enable = false;
  services.printing.enable = false;

  # Server packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    iotop
    ncdu
    bottom

    # Tools
    tmux
    ripgrep
    fd
    jq
    yq

    # Docker tools
    docker-compose
    lazydocker

    # Networking
    curl
    wget
    httpie
  ];
}
