{ acmeEmail, ... }:
{
  services.rkm-backend = {
    enable = true;
    port = 3300;
    host = "127.0.0.1";
    databaseUrl = "postgresql://rkm:rkm@localhost:5432/rkm_cms";
    environmentFile = "/var/lib/rkm-backend/app.env";
    nginx = {
      enable = true;
      domain = "api.rajawalikaryamulya.co.id";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };
}
