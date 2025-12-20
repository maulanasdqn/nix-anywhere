{ ... }:
{
  system.defaults.dock = {
    # Hide dock completely
    autohide = true;
    autohide-delay = 1000000.0;  # Essentially never shows
    autohide-time-modifier = 0.0;
    expose-animation-duration = 0.1;
    launchanim = false;
    show-recents = false;
    tilesize = 1;  # Smallest possible
    magnification = false;
    mineffect = "scale";
    orientation = "bottom";
    persistent-apps = [ ];
    static-only = true;  # Only show running apps (none if empty)
    mru-spaces = false;
  };
}
