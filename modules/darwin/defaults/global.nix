{ ... }:
{
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;

    ApplePressAndHoldEnabled = false;
    KeyRepeat = 1;
    InitialKeyRepeat = 10;

    NSAutomaticWindowAnimationsEnabled = false;
    NSWindowResizeTime = 0.001;

    _HIHideMenuBar = true;

    AppleEnableSwipeNavigateWithScrolls = false;

    AppleFontSmoothing = 0;

    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "64" = { enabled = false; };
        "65" = { enabled = false; };
      };
    };

    "com.apple.dock" = {
      workspaces-swoosh-animation-off = true;
      expose-animation-duration = 0.1;
      springboard-show-duration = 0;
      springboard-hide-duration = 0;
    };

    "com.apple.universalaccess" = {
      reduceMotion = true;
      reduceTransparency = true;
    };

    "NSGlobalDomain" = {
      NSAppSleepDisabled = true;
    };

    "com.apple.finder" = {
      DisableAllAnimations = true;
      FXEnableExtensionChangeWarning = false;
    };

    "com.apple.Siri" = {
      StatusMenuVisible = false;
      UserHasDeclinedEnable = true;
    };

    "com.apple.gamed" = {
      Disabled = true;
    };

    "com.apple.mail" = {
      DisableInlineAttachmentViewing = true;
      AddressesIncludeNameOnPasteboard = false;
    };

    "com.apple.Safari" = {
      IncludeInternalDebugMenu = true;
      WebKitDeveloperExtrasEnabledPreferenceKey = true;
    };

    "com.apple.CrashReporter" = {
      DialogType = "none";
    };

    "com.apple.frameworks.diskimages" = {
      skip-verify = true;
      skip-verify-locked = true;
      skip-verify-remote = true;
    };

    "com.apple.ImageCapture" = {
      disableHotPlug = true;
    };
  };

  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
  };
}
