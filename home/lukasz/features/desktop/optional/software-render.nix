{ pkgs, ... }:
{
  home.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = 1;
  };
}
