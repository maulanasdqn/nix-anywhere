{ config, secretsFile, ... }:
{
  sops = {
    defaultSopsFile = secretsFile;

    age = {
      # Use the server's SSH host key converted to age
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Generated age key location (will be created from SSH key)
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      # Personal website environment
      "personal_website_env" = {
        mode = "0400";
        owner = "root";
      };

      # RKM backend environment
      "rkm_backend_env" = {
        mode = "0400";
        owner = "root";
      };

      # Rclone config for backups
      "rclone_config" = {
        mode = "0400";
        owner = "root";
      };
    };
  };
}
