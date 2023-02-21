{ config, pkgs, lib, ... }: {

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.local/share/password-store"; };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-import ]);
  };

  # Ensure the password store things are in the systemd session
  systemd.user.sessionVariables = config.programs.password-store.settings;

  home.persistence = {
    "/persist/home/lukasz".directories = [ ".local/share/password-store" ];
  };
}
