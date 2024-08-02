{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    let
      resolve-desktop = makeDesktopItem {
        name = "davinci-resolve";
        desktopName = "Davinci Resolve";
        genericName = "Davinci Resolve";
        keywords = [
          "Video"
          "Editor"
        ];
        comment = "Edit video";
        type = "Application";
        terminal = false;
        startupWMClass = "resolve";
        exec = "davinci-resolve";
        mimeTypes = [ "application/x-resolveproj" ];
      };
    in
    [
      davinci-resolve
      resolve-desktop
    ];
}
