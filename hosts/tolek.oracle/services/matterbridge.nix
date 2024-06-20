{
  pkgs,
  lib,
  config,
  ...
}: {
  # sops.secrets = {
  #   matterbridge-config = {
  #     owner = "matterbridge";
  #     group = "matterbridge";
  #     sopsFile = ../secrets.yaml;
  #   };
  # };
  # services.matterbridge = {
  #   enable = true;
  #   configPath = config.sops.secrets.matterbridge-config.path;
  # };
  services.pantalaimon-headless.instances.headscale = {
    listenPort = 20662;
    homeserver = "https://matrix.dechnik.net";
    extraSettings = {
      IgnoreVerification = true;
      UseKeyring = false;
    };
  };
}
