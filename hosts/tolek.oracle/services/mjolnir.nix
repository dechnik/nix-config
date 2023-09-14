{ config, ... }:
{
  sops.secrets = {
    mjolnir-password = {
      owner = "mjolnir";
      group = "mjolnir";
      sopsFile = ../secrets.yaml;
    };
  };

  services.mjolnir = {
    enable = true;
    pantalaimon = {
      enable = true;
      options = {
        listenAddress = "127.0.0.1";
      #   listenPort = 8100;
      };
      username = "mjolnir";
      passwordFile = config.sops.secrets.mjolnir-password.path;
    };
    homeserverUrl = "https://matrix.dechnik.net";
    managementRoom = "!MAtniYIojErvlOBVAo:dechnik.net";

    settings = {
      protectAllJoinedRooms = true;
    };
  };
  systemd.services.mjolnir = {
    after = [
      "matrix-synapse.target"
    ];
  };
  # services.pantalaimon-headless.instances.mjolnir = {
  #   listenAddress = "127.0.0.1";
  #   listenPort = 8100;
  # };
}
