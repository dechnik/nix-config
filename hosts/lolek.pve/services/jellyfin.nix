{ pkgs, lib, config, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  environment.systemPackages = with pkgs; [ jellyfin-ffmpeg ];
  environment.persistence = {
    "/persist".directories = [ "/var/lib/jellyfin" ];
  };
}
