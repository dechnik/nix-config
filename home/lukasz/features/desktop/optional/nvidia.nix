{ pkgs, ... }:
{
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = 1;
  };
}
