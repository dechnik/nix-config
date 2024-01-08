{
  fonts = import ./fonts.nix;
  rgbdaemon = import ./rgbdaemon.nix;
  shellcolor = import ./shellcolor.nix;
  monitors = import ./monitors.nix;
  pass-secret-service = import ./pass-secret-service.nix;
  mail = import ./mail.nix;
  wallpaper = import ./wallpaper.nix;
  xpo = import ./xpo.nix;
  # xdg-portal = import ./xdg-portal.nix;
}
