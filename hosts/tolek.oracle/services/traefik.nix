{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.traefik;
in
{
  sops.secrets."traefik-config.json" = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.traefik.name;
  };

  services.traefik.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.traefik.staticConfigFile = "/var/lib/traefik/config.yml";

  users.users.traefik.extraGroups = [ "acme" ];
}
