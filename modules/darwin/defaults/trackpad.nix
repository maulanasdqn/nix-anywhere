{ ... }:
{
  system.defaults.trackpad = {
    TrackpadThreeFingerHorizSwipeGesture = 2;
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.enableSecondaryClick" = true;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 2;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 2;
    };
  };
}
