{ config, ... }: {
  # Wireless secrets stored through sops
  sops.secrets.wireless = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets.wireless.path
    ];
    profiles = {
      biuro-wifi = {
        connection = {
          id = "biuro-wifi";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "biuro";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$PSK_BIURO";
        };
      };
      dziadowo5-wifi = {
        connection = {
          id = "dziadowo5-wifi";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "dziadowo5";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$PSK_HOME";
        };
      };
    };
  };
  # networking.wireless = {
  #   enable = true;
  #   fallbackToWPA2 = false;
  #   # Declarative
  #   environmentFile = config.sops.secrets.wireless.path;
  #   networks = {
  #     "dziadowo5" = {
  #       psk = "@PSK_HOME@";
  #     };
  #     "biuro" = {
  #       psk = "@PSK_BIURO@";
  #     };
  #     "NETIASPOT-D504A0" = {
  #       psk = "@PSK_LUBSKO@";
  #     };
  #     "edge30_3887" = {
  #       psk = "@PSK_MOTO@";
  #     };
  #   };
  # };
}
