# Security module with firewall rules and rate limiting
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security.rateLimit;
in
{
  options.security.rateLimit = {
    enable = mkEnableOption "Enable rate limiting for nginx";

    zones = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          rate = mkOption {
            type = types.str;
            default = "10r/s";
            description = "Rate limit (e.g., 10r/s, 1r/m)";
          };
          burst = mkOption {
            type = types.int;
            default = 20;
            description = "Burst size";
          };
          nodelay = mkOption {
            type = types.bool;
            default = true;
            description = "Use nodelay mode";
          };
        };
      });
      default = {};
      description = "Rate limiting zones";
    };
  };

  config = mkIf cfg.enable {
    # Define rate limiting zones in nginx http block
    services.nginx.appendHttpConfig = let
      zoneConfigs = mapAttrsToList (name: zone:
        "limit_req_zone $binary_remote_addr zone=${name}:10m rate=${zone.rate};"
      ) cfg.zones;
    in ''
      # Rate limiting zones
      ${concatStringsSep "\n" zoneConfigs}

      # Connection limiting
      limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;

      # Request size limits
      client_max_body_size 100m;
      client_body_buffer_size 128k;

      # Timeouts for DDoS protection
      client_body_timeout 10s;
      client_header_timeout 10s;
      keepalive_timeout 30s;
      send_timeout 10s;

      # Hide nginx version
      server_tokens off;

      # Security headers (applied globally)
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    '';
  };
}
