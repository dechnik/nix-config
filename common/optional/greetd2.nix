{ pkgs, ... }:
let
  user = "lukasz";
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  sway-kiosk =
    command:
    "${pkgs.sway}/bin/sway --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
      output * bg #000000 solid_color
      exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
    ''}";
in
{
  environment.systemPackages = with pkgs; [ bibata-cursors ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = sway-kiosk "${gtkgreet} -l -c '$SHELL -l'";
        inherit user;
      };
      initial_session = {
        command = "$SHELL -l";
        inherit user;
      };
    };
  };
  security = {
    # unlock GPG keyring on login
    pam.services.greetd.gnupg.enable = true;
    # pam.services = {
    #   greetd.enableGnomeKeyring = true;
    # };
    polkit.enable = true;
  };
}
