{ pkgs, ... }: {
  home.packages = with pkgs; [ ranger ];
  home.file.".config/ranger/rc.conf".source = ./rc.conf;
  home.file.".config/ranger/plugins".source = ./plugins;
}
