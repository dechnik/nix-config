{ pkgs,
  lib,
  config,
  ...
}: let
  contexts-config = import ./contexts.nix {inherit config lib;};
  maildirBase = "${config.xdg.dataHome}/mail";
in {
  home.persistence = {
    "/persist/mail/lukasz" = {
      directories = [
        ".local/share/mail"
      ];
      allowOther = true;
    };
  };
}
