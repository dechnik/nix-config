{ inputs
, pkgs
, ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dechnik/nix-config/master/home/lukasz/features/desktop/wall.png";
    sha256 = "37bfdbb9cd427e2c6ebee1de458f6a96704d47962220332c5b7e2e316fef77e0";
  };
}
