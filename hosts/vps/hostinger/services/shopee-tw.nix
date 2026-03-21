{ shopee-tw, lib, pkgs, ... }:
{
  imports = [ shopee-tw.nixosModules.default ];

  services.shopee-scraper = {
    enable = true;
    port = 3010;
    logLevel = "info";
    maxConcurrentPages = 3;
    requestTimeoutSecs = 45;
    retryAttempts = 3;
    useRemoteChrome = true;
    chromeDebugPort = 9222;
  };
}
