{ config, ... }:
{
  services.nix-pilot = {
    enable = true;
    port = 3001;
    address = "127.0.0.1";
    auth = {
      enable = true;
      username = "admin";
      # Password read from sops secret via script
      password = "temp";  # Will be overwritten by activation script
    };
  };

  # Activation script to set password from sops secret
  system.activationScripts.nix-pilot-password = {
    deps = [ "etc" ];
    text = ''
      if [ -f ${config.sops.secrets.nix_pilot_password.path} ]; then
        PASSWORD=$(cat ${config.sops.secrets.nix_pilot_password.path})
        # nix-pilot reads config from its state directory
        mkdir -p /var/lib/nix-pilot
        echo "$PASSWORD" > /var/lib/nix-pilot/.password
        chmod 600 /var/lib/nix-pilot/.password
      fi
    '';
  };

  systemd.services.nix-pilot = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  services.nginx.virtualHosts."manage.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
    # Disable caching for WASM/JS files to prevent version mismatches
    locations."/pkg/" = {
      proxyPass = "http://127.0.0.1:3001";
      extraConfig = ''
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
      '';
    };
  };

  services.nginx.virtualHosts."api-manage.msdqn.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001/api/";
      proxyWebsockets = true;
    };
  };
}
