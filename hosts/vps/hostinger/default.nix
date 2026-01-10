{
  hostname,
  ipAddress,
  gateway,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ../../../profiles/server.nix
    ./services/personal-website.nix
    ./services/rkm-backend.nix
    ./services/rkm-frontend.nix
  ];

  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.ens18.ipv4.addresses = [
      {
        address = ipAddress;
        prefixLength = 24;
      }
    ];
    defaultGateway = gateway;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
  };
}
