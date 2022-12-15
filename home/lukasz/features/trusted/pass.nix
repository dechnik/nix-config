{ pkgs, lib, ... }: {

  programs.password-store = {
    enable = true;
    settings = { PASSWORD_STORE_DIR = "$HOME/.local/share/password-store"; };
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  home.persistence = {
    "/persist/home/lukasz".directories = [ ".local/share/password-store" ];
  };
}
