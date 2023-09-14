{}:
{
  services.mjolnir = {
    pantalaimon = {
      enable = true;
      options = {
        listenAddress = "127.0.0.1";
        listenPort = 8100;
      };
    };

    settings = {
      protectAllJoinedRooms = true;
    };
  };
  systemd.services.mjolnir = {
    serviceConfig = {
      SupplementaryGroups = [ "keys" ];
      Restart = lib.mkForce "always";
      RestartSec = 3;
    };
    unitConfig.StartLimitIntervalSec = 0;
  };
  services.pantalaimon-headless.instances.mjolnir = {
    listenAddress = "127.0.0.1";
    listenPort = 8100;
  };
}
