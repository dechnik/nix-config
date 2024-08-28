{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (_: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}" GTK_USE_PORTAL=0'';

  lukaszCfg = homeCfgs.lukasz;
  wallpaper = lukaszCfg.wallpaper;

  sway-kiosk =
    command:
    "${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
      output * bg #000000 solid_color
      xwayland disable
      input "type:touchpad" {
        tap enabled
      }
      exec '${vars} ${command}; ${pkgs.sway}/bin/swaymsg exit'
    ''}";
in
{
  users.extraUsers.greeter = {
    # For caching and such
    home = "/tmp/greeter-home";
    createHome = true;
  };

  programs.regreet = {
    enable = true;
    iconTheme = lukaszCfg.gtk.iconTheme;
    theme = lukaszCfg.gtk.theme;
    font = lukaszCfg.fontProfiles.regular;
    cursorTheme = {
      inherit (lukaszCfg.gtk.cursorTheme) name package;
    };
    settings = {
      background = {
        path = wallpaper;
        fit = "Cover";
      };
    };
  };
  services.greetd = {
    enable = true;
    settings.default_session.command = sway-kiosk (lib.getExe config.programs.regreet.package);
  };
}
