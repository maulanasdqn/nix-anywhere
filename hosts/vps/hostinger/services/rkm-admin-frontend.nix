{ acmeEmail, ... }:
{
  services.rkm-admin-frontend = {
    enable = true;
    domain = "cms.rajawalikaryamulya.co.id";
    enableSSL = true;
    acmeEmail = acmeEmail;
  };
}
