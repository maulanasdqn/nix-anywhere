{ acmeEmail, ... }:
{
  services.verychic-frontend = {
    enable = true;
    domain = "verychic.msdqn.dev";
    acmeEmail = acmeEmail;  # Required by module, but nginx-ingress handles SSL
  };
}
