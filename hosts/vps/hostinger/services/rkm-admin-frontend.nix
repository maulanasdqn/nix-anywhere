{ ... }:
{
  services.rkm-admin-frontend = {
    enable = true;
    port = 3100;
    host = "0.0.0.0";  # Bind to all interfaces for k8s access
    # nginx handled by k8s nginx-ingress
    nginx.enable = false;
  };
}
