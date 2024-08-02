{
  config,
  pkgs,
  lib,
}:
let
  package = pkgs.tailscale;
  tailscale =
    {
      hostname ? ''${builtins.replaceStrings [ ".dechnik.net" ] [ "" ] config.networking.fqdn}'',
      loginServer ? "https://tailscale.dechnik.net",
      reset ? true,
      reauth ? false,
      ssh ? true,
      tags ? [ ],
    }:
    {
      imports = [ ../../modules/nixos/tailscale2-userpace.nix ];

      sops.secrets.headscale-client-preauthkey = {
        sopsFile = ../secrets.yaml;
      };

      # make the tailscale command usable to users
      environment.systemPackages = [ package ];

      # enable the tailscale service
      services.tailscale2 = {
        enable = true;
        inherit package;

        authKeyFile = config.sops.secrets.headscale-client-preauthkey.path;

        extraUpFlags =
          [ ''--hostname=${hostname}'' ]
          ++ lib.optional ((builtins.stringLength loginServer) > 0) "--login-server=${loginServer}"
          ++ lib.optional reauth "--force-reauth"
          ++ lib.optional reset "--reset"
          ++ lib.optional ssh "--ssh"
          ++ lib.optional (
            (builtins.length tags) > 0
          ) ''--advertise-tags=${builtins.concatStringsSep "," tags}'';
      };
    };
in
{
  inherit tailscale;
}
