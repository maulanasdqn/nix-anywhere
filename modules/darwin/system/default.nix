{ username, ... }:
{
  system.stateVersion = 5;

  # Never sleep unless lid is closed
  power.sleep.computer = "never";
  power.sleep.display = "never";
  power.sleep.harddisk = "never";
  system.primaryUser = username;

  # Keyboard settings - swap Caps Lock and Escape using hidutil
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      # Caps Lock (0x39) -> Escape (0x29)
      {
        HIDKeyboardModifierMappingSrc = 30064771129;  # 0x700000039
        HIDKeyboardModifierMappingDst = 30064771113;  # 0x700000029
      }
      # Escape (0x29) -> Caps Lock (0x39)
      {
        HIDKeyboardModifierMappingSrc = 30064771113;  # 0x700000029
        HIDKeyboardModifierMappingDst = 30064771129;  # 0x700000039
      }
    ];
  };

  # Launchd daemon to apply key mapping on boot
  launchd.daemons.keyboard-remap = {
    serviceConfig = {
      Label = "com.local.keyboard-remap";
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        ''{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771113},{"HIDKeyboardModifierMappingSrc":30064771113,"HIDKeyboardModifierMappingDst":30064771129}]}''
      ];
      RunAtLoad = true;
    };
  };
}
