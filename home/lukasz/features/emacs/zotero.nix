{ pkgs, ... }:
{
  isRunning = "${pkgs.procps}/bin/pgrep 'zotero' &> /dev/null";
}
