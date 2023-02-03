{
  config,
  pkgs,
  inputs,
  ...
}: {
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
      };
    };
  };
}
