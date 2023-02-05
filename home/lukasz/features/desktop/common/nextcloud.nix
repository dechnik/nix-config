{ pkgs, ... }: {
  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".config/Nextcloud" ];
  };
}
