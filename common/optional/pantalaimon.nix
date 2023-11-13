{
  pkgs,
  lib,
  config,
  ...
}: {
  services.pantalaimon-headless.instances.dechnik = {
    logLevel = "debug";
    listenAddress = "127.0.0.1";
    listenPort = 20662;
    homeserver = "https://dechnik.net";
  };
}
