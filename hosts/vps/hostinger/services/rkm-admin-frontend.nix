{ ... }:
{
  services.rkm-admin-frontend = {
    enable = true;
    port = 3100;
    nginx = {
      enable = true;
      domain = "cms.rajawalikaryamulya.co.id";
      enableSSL = true;
    };
  };
}
