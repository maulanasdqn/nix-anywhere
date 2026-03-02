{ acmeEmail, ... }:
{
  services.verychic-frontend = {
    enable = true;
    port = 3200;
    domain = "verychic.msdqn.dev";
    acmeEmail = acmeEmail;
    imageTag = "testing";
  };
}
