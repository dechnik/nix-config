{ inputs, pkgs, ... }:
let
  website = inputs.website.packages.${pkgs.system}.main;
in
{
  services.nginx.virtualHosts =
    let
      days = n: toString (n * 60 * 60 * 24);
    in
    {
      "dev.dechnik.net" = {
        extraConfig = ''
          access_log /var/log/nginx/dechnik.net.access.log;
        '';
        locations = {
          # My key moved to openpgp.org
          "/35655963B7835180125FE55DD7BCC570927C355B.asc" = {
            return = "301 https://keys.openpgp.org/vks/v1/by-fingerprint/35655963B7835180125FE55DD7BCC570927C355B";
          };
          "/" = {
            root = "${website}/public";
          };
          "/assets/" = {
            root = "${website}/public";
            extraConfig = ''
              add_header Cache-Control "max-age=${days 30}";
            '';
          };
          "=/nix" = {
            # Script to download static nix
            alias = ./scripts/nix-installer.sh;
          };

          "=/setup-gpg" = {
            alias = ./scripts/setup-gpg.sh;
          };
        };
      };
    };
}
