{
  pkgs,
  config,
  ...
}: {
  # disabledModules = ["services/continuous-integration/github-runners.nix"];
  #
  # imports = [
  #   "${flakes.nixpkgs-unstable}/nixos/modules/services/continuous-integration/github-runners.nix"
  # ];

  sops.secrets.github-nix-config-token = {
    sopsFile = ../secrets.yaml;
  };

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
    url = "https://github.com/dechnik/nix-config";
    replace = true;
    extraLabels = ["nixos" "docker" "lukasz-${config.networking.hostName}"];
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
    name = "lukasz-${config.networking.hostName}";

    # Replace this with the path to the GitHub Actions runner token on
    # your disk.
    tokenFile = config.sops.secrets.github-nix-config-token.path;
  };
}
