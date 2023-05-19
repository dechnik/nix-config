{ pkgs, config, ... }:
{
  sops.secrets.cache-sig-key = {
    sopsFile = ../secrets.yaml;
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets.cache-sig-key.path;
      # TODO: temporary fix for NixOS/nix#7704
      package = pkgs.nix-serve.override { nix = pkgs.nixVersions.nix_2_12; };
    };
    traefik.dynamicConfigOptions.http = {
      services.cache = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.nix-serve.port}"; }];
      };

      routers.cache = {
        rule = "Host(`cache.dechnik.net`)";
        service = "cache";
        entryPoints = [ "web" ];
      };
    };
  };
}
