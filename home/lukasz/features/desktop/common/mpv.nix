{ pkgs, config, ... }:
{
  programs = {
    mpv = {
      enable = true;
      defaultProfiles = [ "gpu-hq" ];
      config = {
        profile = "gpu-hq";
        hwdec = "vaapi";
        ytdl-format = "bestvideo[height<=2160]+bestaudio/best[height<=2160]";
      };
      scripts = [
        pkgs.mpvScripts.mpris
        pkgs.mpvScripts.quality-menu
      ];
      bindings = {
        "F" = "script-binding quality_menu/video_formats_toggle";
        "Alt+f" = "script-binding quality_menu/audio_formats_toggle";
      };
    };
  };
}
