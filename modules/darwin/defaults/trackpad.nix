{ ... }:
{
  system.defaults.trackpad = {
    # Enable three finger swipe to switch spaces
    TrackpadThreeFingerHorizSwipeGesture = 2;
  };

  # Additional trackpad settings via NSGlobalDomain
  system.defaults.NSGlobalDomain = {
    # Enable three finger drag
    "com.apple.trackpad.enableSecondaryClick" = true;
  };

  # Swipe between full-screen apps with three fingers
  system.defaults.CustomUserPreferences = {
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 2;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 2;
    };
  };
}
