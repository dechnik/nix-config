{
  pkgs,
  inputs,
  config,
  ...
}: let
  port = 56789;
in {
  environment.systemPackages = [pkgs.attic];
  sops.secrets.attic-env = {
    sopsFile = ../secrets.yaml;
  };

  imports = [
    inputs.attic.nixosModules.atticd
  ];

  services = {
    # https://lgug2z.com/articles/deploying-a-cloudflare-r2-backed-nix-binary-cache-attic-on-fly-io/
    # https://lgug2z.com/articles/building-and-privately-caching-x86-and-aarch64-nixos-systems-on-github-actions/

    # env ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="" atticadm make-token --sub "lukasz" --validity "10y" --pull "*"
    # --push "*" --create-cache "*" --configure-cache "*" --configure-cache-retention "*" --destroy-cache "*" --delete "*"
    # -f config.toml
    atticd = {
      enable = true;

      credentialsFile = config.sops.secrets.attic-env.path;

      settings = {
        storage = {
          type = "local";
          path = "/mnt/sg/attic";
        };
        listen = "[::]:${toString port}";

        # Data chunking
        #
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };
    traefik.dynamicConfigOptions.http = {
      services.attic = {
        loadBalancer.servers = [{ url = "http://127.0.0.1:${toString port}"; }];
      };

      routers.attic = {
        rule = "Host(`attic.dechnik.net`)";
        service = "attic";
        entryPoints = [ "web" ];
      };
    };
  };
}
