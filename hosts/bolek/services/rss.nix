{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      full-text-rss = {
        autoStart = true;
        image = "heussd/fivefilters-full-text-rss:latest";
        ports = [ "50000:80" ];
      };
      freshrss = {
        autoStart = true;
        image = "lscr.io/linuxserver/freshrss:latest";
        ports = [ "49999:80" ];
        environment = {
          "TZ" = "Europe/Warsaw";
        };
        volumes = [ "/var/lib/freshrss:/config" ];
      };
    };
  };
  environment.persistence = {
    "/persist".directories = [ "/var/lib/freshrss" ];
  };
}
