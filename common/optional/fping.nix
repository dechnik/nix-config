{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ fping ];
  security.wrappers.fping = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw+ep";
    source = "${pkgs.fping}/bin/fping";
  };
}
