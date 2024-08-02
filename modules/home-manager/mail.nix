{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.mailhost = mkOption {
    type = types.str;
    example = "";
  };
}
