{ lib, config }:
with lib;
with builtins;
let
  baseDomain = ".dechnik.net";

  currentSite = builtins.replaceStrings [ baseDomain ] [ "" ] config.networking.domain;

  consulPeers = mapAttrs (key: value: value.consul) (
    filterAttrs (key: hasAttr "consul") (removeAttrs sites [ currentSite ])
  );

  consul = mapAttrs (key: value: value.consul) (filterAttrs (key: hasAttr "consul") sites);

  nameservers = lib.unique (lib.flatten (attrValues (mapAttrs (name: site: site.nameservers) sites)));

  sites = {
    pve =
      let
        ipv4Gateway = "10.60.0.1";
      in
      {
        name = "pve";
        nameservers = [ ipv4Gateway ];
        consul = ipv4Gateway;
        # openvpn = "10.60.200.0";
        k3s = {
          master = "10.60.0.111";
          clusterCidr = "10.60.4.0/24";
          serviceCidr = "10.60.5.0/24";
        };
        inherit ipv4Gateway;
      };
    oracle =
      let
        ipv4Gateway = "10.61.0.1";
      in
      {
        name = "oracle";
        nameservers = [ ipv4Gateway ];
        consul = ipv4Gateway;
        # openvpn = "10.60.200.0";
        # k3s = {
        #   master = "10.60.0.111";
        #   clusterCidr = "10.60.4.0/24";
        #   serviceCidr = "10.60.5.0/24";
        # };
        inherit ipv4Gateway;
      };
    # hetzner =
    #   let
    #     ipv4Gateway = "10.62.0.1";
    #   in
    #   {
    #     name = "hetzner";
    #     nameservers = [ ipv4Gateway ];
    #     consul = ipv4Gateway;
    #     # openvpn = "10.60.200.0";
    #     # k3s = {
    #     #   master = "10.60.0.111";
    #     #   clusterCidr = "10.60.4.0/24";
    #     #   serviceCidr = "10.60.5.0/24";
    #     # };
    #     inherit ipv4Gateway;
    #   };
  };
in
{
  inherit
    baseDomain
    currentSite
    consulPeers
    consul
    nameservers
    sites
    ;
}
