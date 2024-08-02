{
  config,
  lib,
  pkgs,
  ...
}:
let
  consul = import ../functions/consul.nix { inherit lib; };
in
{
  services = {
    nginx = {
      enable = true;

      statusPage = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      clientMaxBodySize = "300m";
    };
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
