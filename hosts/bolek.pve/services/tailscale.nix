{
  config,
  pkgs,
  lib,
  ...
}: let
  wireguardHosts = import ../../../metadata/wireguard.nix;
  wireguardConfig = wireguardHosts.servers.pve;
in
  (import ../../../common/functions/tailscale.nix {inherit config pkgs lib;}).tailscale
  {
    preAuthKey = "b2e52bc0373411481e6bc568af3"; # onetime key
    loginServer = "https://tailscale.dechnik.net";
    reauth = false;
    exitNode = true;
    advertiseRoutes = wireguardConfig.additional_networks;
    tags = ["tag:pve" "tag:server"];
  }
