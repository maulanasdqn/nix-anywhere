{ acmeEmail, ... }:
{
  services.hpyd = {
    enable = true;
    port = 3200;
    host = "127.0.0.1";
    nginx = {
      enable = true;
      domain = "hpyd.msdqn.dev";
      enableSSL = true;
      acmeEmail = acmeEmail;
    };
  };
}
