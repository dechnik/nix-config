{ config, lib, ... }:
{
  services = {
    transmission = {
      enable = true;
      openFirewall = true;
      openRPCPort = true;
      downloadDirPermissions = "777";
      settings = {
        rpc-bind-address = "0.0.0.0";
        download-dir = "/media/new";
        incomplete-dir = "/media/incomplete";
        rpc-whitelist = "10.*.*.* 127.0.0.1 localhost";
        # rpc-host-whitelist = "transmission.i.graysonhead.net";
      };
    };
  };
  users.groups.transmission.members = [ "transmission" config.services.jellyfin.user ];
}
