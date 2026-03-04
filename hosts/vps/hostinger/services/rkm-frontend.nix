{ ... }:
{
  services.rkm-frontend = {
    enable = true;
    domain = "rajawalikaryamulya.co.id";
    extraDomains = [ "www.rajawalikaryamulya.co.id" ];
    # SSL handled by k8s cert-manager
    enableSSL = false;
  };
}
