{ config, outputs, lib, ... }:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
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
      trusted = lib.hm.dag.entryBefore [ "net" ] {
        host = "dechnik.net *.dechnik.net *.panther-crocodile.ts.net";
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

  home.file = {
    ".ssh/config.d/dechnik" = {
      text = ''
        Host k3s*.pve
          HostName %h.dechnik.net
          User lukasz
          Port 22
      '';
    };
  };
}
