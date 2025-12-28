{ ... }:
{
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
    ShowStatusBar = true;

    # Performance optimizations
    FXDefaultSearchScope = "SCcf"; # Search current folder only (faster)
    _FXShowPosixPathInTitle = true;
    QuitMenuItem = true; # Allow quitting Finder
  };

  # Disable .DS_Store on network/USB (faster file operations)
  system.defaults.CustomUserPreferences."com.apple.desktopservices" = {
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };
}
