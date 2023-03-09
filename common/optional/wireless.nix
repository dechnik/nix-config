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
    };

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
    extraConfig = ''
      update_config=1
    '';
  };
  # Ensure group exists
  users.groups.network = { };

  # Persist imperative config
  # environment.persistence = {
  #   "/persist".files = [
  #     "/etc/wpa_supplicant.conf"
  #   ];
  # };
}
