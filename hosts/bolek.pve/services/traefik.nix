{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  traefik = import ../../../common/functions/traefik.nix { inherit config lib pkgs; };
in
lib.mkMerge [
  {
    services.traefik.dynamicConfigOptions.http = {
      serversTransports = {
        insecure-skip-verify.insecureSkipVerify = true;
      };

      routers.dashboard = {
        rule = "Host(`traefik.pve.dechnik.net`) ";
        service = "api@internal";
        entryPoints = [ "web" ];
        middlewares = [
          "dechnik-ips"
          "auth"
        ];
      };
      services.nc = {
        loadBalancer.servers = [ { url = "http://10.60.0.2:80"; } ];
      };
      services.yt = {
        loadBalancer.servers = [ { url = "http://10.60.0.2:3000"; } ];
      };
      services.ai = {
        loadBalancer.servers = [ { url = "http://10.60.0.2:8080"; } ];
      };
      services.ob = {
        loadBalancer.servers = [ { url = "http://10.60.0.3:9000"; } ];
      };
      services.sg = {
        loadBalancer.servers = [ { url = "http://127.0.0.1:3080"; } ];
      };
      services.tj = {
        loadBalancer.servers = [ { url = "http://127.0.0.1:8880"; } ];
      };

      routers.nc = {
        rule = "Host(`nc.dechnik.net`)";
        service = "nc";
        entryPoints = [ "web" ];
      };
      routers.sg = {
        rule = "Host(`sg.dechnik.net`)";
        service = "sg";
        entryPoints = [ "web" ];
      };
      routers.ob = {
        rule = "Host(`ob.dechnik.net`)";
        service = "ob";
        entryPoints = [ "web" ];
      };
      routers.yt = {
        rule = "Host(`yt.pve.dechnik.net`)";
        service = "yt";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" ];
      };
      routers.ai = {
        rule = "Host(`ai.dechnik.net`)";
        service = "ai";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" ];
      };
      routers.tj = {
        rule = "Host(`tj.dechnik.net`)";
        service = "tj";
        entryPoints = [ "web" ];
        middlewares = [ "dechnik-ips" ];
      };
      routers.dechnik = {
        rule = "Host(`dev.dechnik.net`)";
        service = "nc";
        entryPoints = [ "web" ];
      };
    };
  }

  (traefik.traefik { site = "pve"; })
]
