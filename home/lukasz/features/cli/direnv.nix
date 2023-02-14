{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".local/share/direnv" ];
  };
}
