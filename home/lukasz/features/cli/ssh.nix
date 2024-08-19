{
  outputs,
  lib,
  ...
}:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
  hosts = builtins.map (host: builtins.replaceStrings [ "." ] [ "-" ] host) hostnames;
  allHosts = hostnames ++ hosts;
  #  ++ map (host: builtins.replaceStrings [ "." ] [ "_" ] host) builtins.attrNames outputs.nixosConfigurations;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      net = {
        host = builtins.concatStringsSep " " allHosts;
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
          }
        ];
      };
      trusted = lib.hm.dag.entryBefore [ "net" ] {
        host = "dechnik.net *.dechnik.net *.panther-crocodile.ts.net";
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
          }
          {
            bind.address = ''/%d/.waypipe/server.sock'';
            host.address = ''/%d/.waypipe/client.sock'';
          }
        ];
        forwardX11 = true;
        forwardX11Trusted = true;
        setEnv.WAYLAND_DISPLAY = "wayland-waypipe";
        extraOptions.StreamLocalBindUnlink = "yes";
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
