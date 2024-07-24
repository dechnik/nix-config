{ config
, pkgs
,
}:
let
  gh-runner =
    { name ? ''lukasz-${config.networking.hostName}''
    , extraLabels ? ["nixos" "docker" "lukasz-${config.networking.hostName}"]
    , url ? "https://github.com/dechnik/nix-config"
    , tokenFile
    ,
    }: {
      virtualisation.docker.enable = true;
      nix.settings.trusted-users = [
        "github-runner"
      ];

      users.users.github-runner = {
        isSystemUser = true;
        group = "docker";
      };

      # The GitHub Actions self-hosted runner service.
      services.github-runners.nix-config = {
        enable = true;
        package = pkgs.github-runner;
        inherit url;
        replace = true;
        inherit extraLabels;
        user = "github-runner";

        # Justifications for the packages:
        extraPackages = with pkgs; [
          docker
          nix
          nodejs
          gawk
          curl
          xz
          tailscale
          git
        ] ++
            (builtins.map
            (elem: writeShellScriptBin "${elem}" "echo wanted to run: ${elem} \${@}")
            ["sudo" "apt-get" "apt"]
        );

        # Customize this to include your GitHub username so we can track
        # who is running which node.
        inherit name;

        # Replace this with the path to the GitHub Actions runner token on
        # your disk.
        inherit tokenFile;
      };
    };
in
{
  inherit gh-runner;
}
