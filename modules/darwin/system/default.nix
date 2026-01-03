{ username, ... }:
{
  system.stateVersion = 5;

  power.sleep.computer = "never";
  power.sleep.display = "never";
  power.sleep.harddisk = "never";
  system.primaryUser = username;

  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771113;
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771113;
        HIDKeyboardModifierMappingDst = 30064771129;
      }
    ];
  };

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
