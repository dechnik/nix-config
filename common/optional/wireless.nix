{ config, lib, ... }:
{
  # Wireless secrets stored through sops
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.wireless = {
    enable = true;
    fallbackToWPA2 = false;
    # Declarative
    secretsFile = config.sops.secrets.wireless.path;
    networks = {
      "dziadowo5" = {
        pskRaw = "ext:PSK_HOME";
      };
      "biuro" = {
        pskRaw = "ext:PSK_BIURO";
      };
      "NETIASPOT-D504A0" = {
        pskRaw = "ext:PSK_LUBSKO";
      };
      "edge30_3887" = {
        pskRaw = "ext:PSK_MOTO";
      };
    };

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
    extraConfig = ''
      ctrl_interface=DIR=/run/wpa_supplicant GROUP=${config.networking.wireless.userControlled.group}
      update_config=1
    '';
  };
  # Ensure group exists
  users.groups.network = { };

  systemd.services.wpa_supplicant.preStart = "touch /etc/wpa_supplicant.conf";

  # Persist imperative config
  # environment.persistence = {
  #   "/persist".files = [
  #     "/etc/wpa_supplicant.conf"
  #   ];
  # };
}
