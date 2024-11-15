{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
  ];
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        # QT 5
        (pkgs.libsForQt5.qtstyleplugins.overrideAttrs (old: {
          # Make qtstyleplugins' gtk2 platform theme activate if QT_QPA_PLATFORMTHEME=gtk3
          patches = (old.patches or []) ++ [./qtstyleplugins-gtk3-key.patch];
        }))
      ];
    };
  };
}
