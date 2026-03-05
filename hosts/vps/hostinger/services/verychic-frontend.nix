{ acmeEmail, ... }:
{
  # Disabled - now served via k8s nginx with stable symlinks
  # services.verychic-frontend = {
  #   enable = true;
  #   domain = "verychic.msdqn.dev";
  #   acmeEmail = acmeEmail;
  # };
}
