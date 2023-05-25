{ inputs, pkgs, ... }:
let
  website = inputs.website.packages.${pkgs.system}.main;
in
{
  services.nginx.virtualHosts =
    let days = n: toString (n * 60 * 60 * 24);
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
            # Sadly only works on linux
            alias = pkgs.writeText "nix" ''
              #/bin/sh

              arch="$(uname -m)"
              job="https://hydra.nixos.org/job/nix/master/buildStatic.$arch-linux/latest/download-by-type/file/binary-dist"
              echo "Downloading from: $job"

              mkdir -p "$HOME/.local/bin"
              curl -L "$job" -o "$HOME/.local/bin/nix"
              chmod +x "$HOME/.local/bin/nix"

              mkdir -p "$HOME/.config/nix"
              echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
            '';
          };
        };
      };
    };
}
