{ config, lib, ... }: {
  # Wireless secrets stored through sops
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.wireless = {
    enable = true;
    fallbackToWPA2 = false;
    # Declarative
    environmentFile = config.sops.secrets.wireless.path;
    networks = {
      "dziadowo5" = {
        psk = "@PSK_HOME@";
      };
      "biuro" = {
        psk = "@PSK_BIURO@";
      };
      "NETIASPOT-D504A0" = {
        psk = "@PSK_LUBSKO@";
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
