{ inputs, lib, ... }:
{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 3 generations
      options = "--delete-older-than 14d";
    };
  };
}
