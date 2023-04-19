{ pkgs, ... }: {
  home.packages = with pkgs; [ ranger ];
  home.file.".config/ranger/rc.conf".source = ./rc.conf;
}
