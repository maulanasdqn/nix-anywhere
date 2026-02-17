{ lib, ... }:
{
  system.activationScripts.accessibility.text = ''
    current_motion=$(defaults read com.apple.universalaccess reduceMotion 2>/dev/null || echo "0")
    current_transparency=$(defaults read com.apple.universalaccess reduceTransparency 2>/dev/null || echo "0")

    if [ "$current_motion" != "1" ]; then
      defaults write com.apple.universalaccess reduceMotion -bool true
    fi

    if [ "$current_transparency" != "1" ]; then
      defaults write com.apple.universalaccess reduceTransparency -bool true
    fi

    # Disable all animations system-wide
    defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
    defaults write -g NSScrollAnimationEnabled -bool false
    defaults write -g NSWindowResizeTime -float 0.001
    defaults write -g QLPanelAnimationDuration -float 0
    defaults write -g NSScrollViewRubberbanding -bool false
    defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
    defaults write -g NSToolbarFullScreenAnimationDuration -float 0
    defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

    # Disable Dock animations
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults write com.apple.dock autohide-time-modifier -float 0
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock launchanim -bool false
    defaults write com.apple.dock springboard-show-duration -float 0
    defaults write com.apple.dock springboard-hide-duration -float 0

    # Disable Finder animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Disable Mission Control animations
    defaults write com.apple.universalaccess reduceMotion -bool true

    # Speed up Mission Control
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # Disable send/reply animations in Mail
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true
  '';
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;

    ApplePressAndHoldEnabled = false;
    KeyRepeat = 1;
    InitialKeyRepeat = 10;

    NSAutomaticWindowAnimationsEnabled = false;
    NSWindowResizeTime = 0.001;

    _HIHideMenuBar = false;

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

    "NSGlobalDomain" = {
      NSAppSleepDisabled = true;
      NSScrollAnimationEnabled = false;
      NSWindowResizeTime = 0.001;
      QLPanelAnimationDuration = 0;
      NSBrowserColumnAnimationSpeedMultiplier = 0;
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
      DisableReplyAnimations = true;
      DisableSendAnimations = true;
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

    "com.apple.TimeMachine" = {
      DoNotOfferNewDisksForBackup = true;
    };

    "com.apple.screencapture" = {
      disable-shadow = true;
    };

    "com.apple.helpviewer" = {
      DevMode = true;
    };

    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    "com.apple.print.PrintingPrefs" = {
      "Quit When Finished" = true;
    };

    "com.apple.LaunchServices" = {
      LSQuarantine = false;
    };

    "com.apple.commerce" = {
      AutoUpdate = false;
    };

    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = false;
      AutomaticDownload = false;
      CriticalUpdateInstall = false;
    };

    "com.apple.appstore" = {
      ShowDebugMenu = true;
      WebKitDeveloperExtras = true;
    };
  };

  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
  };
}
