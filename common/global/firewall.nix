{lib, ...}: {
  networking.firewall = {
    enable = true;
    allowPing = true;
    # pingLimit = "--limit 10/minute --limit-burst 5";
    checkReversePath = lib.mkDefault "loose";
    logRefusedConnections = lib.mkDefault false;

    connectionTrackingModules = [
      "ftp"
      "tftp"
      "netbios_sn"
      "snmp"
    ];
  };
}
