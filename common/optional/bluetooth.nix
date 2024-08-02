{
  config,
  pkgs,
  inputs,
  ...
}:
{
  hardware = {
    bluetooth = {
      enable = true;
      package = pkgs.bluez5-experimental;
      # hsphfpd.enable = true;
      settings = {
        # make Xbox Series X controller work
        General = {
          Enable = "Source,Sink,Media,Socket";
          Class = "0x000100";
          # ControllerMode = "bredr";
          FastConnectable = true;
          JustWorksRepairing = "always";
          Privacy = "device";
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };
  services.blueman.enable = true;
  services.pipewire = {
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };
}
