{ pkgs, ... }:
{
  programs.lf = {
    enable = true;
    settings = {
      dircounts = true;
      dirfirst = true;
      drawbox = true;
      icons = true;
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/bin/sh
      unset COLORTERM
      bat --color=always "$1"
    '';
  };
}
