{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.xserver.windowManager.qtile = {
    enable = true;
    backend = "wayland";
    extraPackages =
      python3Packages: with python3Packages; [
        (qtile-extras.overridePythonAttrs (old: {
          doCheck = false;
        }))
      ];
  };
  environment.systemPackages = [ pkgs.qtile ];
}
