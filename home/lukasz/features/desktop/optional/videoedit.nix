{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      # davinci-resolve-patched
      davinci-resolve
    ];
}
