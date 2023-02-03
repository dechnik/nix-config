{ pkgs, ... }:
{
  home.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = 1;
    WLR_NO_HARDWARE_CURSORS = 1;
  };
}
