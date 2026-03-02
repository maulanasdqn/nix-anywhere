{ acmeEmail, ... }:
{
  services.verychic-frontend = {
    enable = true;
    domain = "verychic.msdqn.dev";
    acmeEmail = acmeEmail;
  };
}
