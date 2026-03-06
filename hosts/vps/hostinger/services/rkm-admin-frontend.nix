{ ... }:
{
  services.rkm-admin-frontend = {
    enable = true;
    port = 3100;
    host = "127.0.0.1";
    nginx.enable = false;
  };
}
