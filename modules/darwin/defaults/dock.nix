{ ... }:
{
  system.defaults.dock = {
    # Hide dock completely
    autohide = true;
    autohide-delay = 1000000.0; # Essentially never shows
    autohide-time-modifier = 0.0; # Instant hide
    expose-animation-duration = 0.001; # Instant Mission Control
    launchanim = false; # No bounce animation
    show-recents = false;
    tilesize = 1; # Smallest possible
    magnification = false;
    mineffect = "scale"; # Faster than genie
    orientation = "bottom";
    persistent-apps = [ ];
    static-only = true; # Only show running apps
    mru-spaces = false; # Don't rearrange spaces
    minimize-to-application = true; # Less dock clutter
  };

  # Disable Dashboard
  system.defaults.spaces = {
    spans-displays = false; # Each display has own spaces
  };
}
