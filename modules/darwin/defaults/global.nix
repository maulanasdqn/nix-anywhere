{ ... }:
{
  system.defaults.NSGlobalDomain = {
    # File extensions
    AppleShowAllExtensions = true;

    # Keyboard - blazing fast
    ApplePressAndHoldEnabled = false;
    KeyRepeat = 1; # Fastest repeat
    InitialKeyRepeat = 10; # Shortest delay before repeat

    # Disable ALL animations
    NSAutomaticWindowAnimationsEnabled = false;
    NSWindowResizeTime = 0.001;

    # Hide menu bar
    _HIHideMenuBar = true;

    # Disable transparency for better GPU performance
    AppleEnableSwipeNavigateWithScrolls = false;

    # Faster rendering
    AppleFontSmoothing = 0; # Disable font smoothing (crisper on retina)

    # Disable auto-correct annoyances (also saves CPU)
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Disable natural scrolling if you prefer traditional
    # "com.apple.swipescrolldirection" = false;
  };

  # Disable Spotlight shortcut (Cmd+Space) so Raycast can use it
  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable Spotlight (64 = Cmd+Space)
        "64" = { enabled = false; };
        # Disable Finder search (65)
        "65" = { enabled = false; };
      };
    };

    # Dock performance
    "com.apple.dock" = {
      workspaces-swoosh-animation-off = true;
      expose-animation-duration = 0.1;
      springboard-show-duration = 0;
      springboard-hide-duration = 0;
    };

    # Reduce motion system-wide
    "com.apple.universalaccess" = {
      reduceMotion = true;
      reduceTransparency = true; # Disable transparency effects
    };

    # Disable App Nap (keeps apps responsive)
    "NSGlobalDomain" = {
      NSAppSleepDisabled = true;
    };

    # Finder performance
    "com.apple.finder" = {
      DisableAllAnimations = true;
      FXEnableExtensionChangeWarning = false;
    };

    # Disable Siri (saves resources)
    "com.apple.Siri" = {
      StatusMenuVisible = false;
      UserHasDeclinedEnable = true;
    };

    # Disable Game Center
    "com.apple.gamed" = {
      Disabled = true;
    };

    # Mail - disable if not using
    "com.apple.mail" = {
      DisableInlineAttachmentViewing = true;
      AddressesIncludeNameOnPasteboard = false;
    };

    # Safari - if used, optimize
    "com.apple.Safari" = {
      IncludeInternalDebugMenu = true;
      WebKitDeveloperExtrasEnabledPreferenceKey = true;
    };

    # Disable crash reporter dialog
    "com.apple.CrashReporter" = {
      DialogType = "none";
    };

    # Disable disk image verification (faster mounts)
    "com.apple.frameworks.diskimages" = {
      skip-verify = true;
      skip-verify-locked = true;
      skip-verify-remote = true;
    };

    # Disable Photos from opening automatically
    "com.apple.ImageCapture" = {
      disableHotPlug = true;
    };
  };

  # WindowServer performance
  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
  };
}
