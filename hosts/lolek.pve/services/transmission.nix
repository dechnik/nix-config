{ config, ... }:
{
  services = {
    transmission = {
      enable = true;
      openFirewall = true;
      openRPCPort = true;
      downloadDirPermissions = "777";
      settings = {
        rpc-port = 9091;
        umaks = 0;
        rpc-bind-address = "0.0.0.0";
        download-dir = "/media/new";
        incomplete-dir = "/media/incomplete";
        rpc-whitelist = "100.*.*.* 10.*.*.* 127.0.0.1 localhost";
        # rpc-host-whitelist = "transmission.i.graysonhead.net";
      };
    };
  };
  users.groups.transmission.members = [ "transmission" config.services.jellyfin.user ];
}
