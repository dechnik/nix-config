{ pkgs, ... }: {
  home.persistence = {
    "/persist/mail/lukasz" = {
      directories = [
        ".local/share/mail"
      ];
      allowOther = true;
    };
  };
}
