{ config, outputs, lib, ... }:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
  tailnethosts = lib.mapAttrsToList getTailscaleHosts outputs.nixosConfigurations;
  getTailscaleHosts = _: cfg: lib.replaceStrings [".dechnik.net"] [""] cfg.config.networking.fqdn;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      net = {
        host = builtins.concatStringsSep " " hostnames;
        forwardAgent = true;
        remoteForwards = [{
          bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
          host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
        }];
      };
      tailnet = {
        host = builtins.concatStringsSep " " tailnethosts;
        forwardAgent = true;
        remoteForwards = [{
          bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
          host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
        }];
      };
      trusted = lib.hm.dag.entryBefore [ "net" ] {
        host = "dechnik.net *.dechnik.net";
        forwardAgent = true;
      };
    };
    includes = [
      "/var/run/secrets/ssh-config"
      "config.d/*"
    ];
  };

  home.persistence = {
    "/persist/home/lukasz".directories = [ ".ssh" ];
  };
}
