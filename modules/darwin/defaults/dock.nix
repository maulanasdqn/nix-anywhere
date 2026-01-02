{ ... }:
{
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 1000000.0;
    autohide-time-modifier = 0.0;
    expose-animation-duration = 0.001;
    launchanim = false;
    show-recents = false;
    tilesize = 1;
    magnification = false;
    mineffect = "scale";
    orientation = "bottom";
    persistent-apps = [ ];
    static-only = true;
    mru-spaces = false;
    minimize-to-application = true;
  };

  system.defaults.spaces = {
    spans-displays = false;
  };
}
