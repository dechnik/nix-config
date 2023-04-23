{ config, pkgs, lib, ... }: {

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.local/share/password-store"; };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-import ]);
  };

  services.pass-secret-service = {
    enable = true;
    storePath = "${config.home.homeDirectory}/.local/share/password-store";
    extraArgs = [ "-e${config.programs.password-store.package}/bin/pass" ];
  };

  # Ensure the password store things are in the systemd session
  systemd.user.sessionVariables = config.programs.password-store.settings;

  home.persistence = {
    "/persist/home/lukasz".directories = [ ".local/share/password-store" ];
  };
}
