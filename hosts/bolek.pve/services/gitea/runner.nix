{pkgs, config, ...}:
{
  sops.secrets = {
    gitea-runner = {
      sopsFile = ../../secrets.yaml;
      owner = "gitea-runner";
    };
    gitea-runner2 = {
      sopsFile = ../../secrets.yaml;
      owner = "gitea-runner";
    };
  };
  services.gitea-actions-runner.instances = {
    pve = {
      enable = true;
      url = "https://git.dechnik.net";
      tokenFile = config.sops.secrets.gitea-runner.path;
      name = "pve";
      labels = [
        "native:host"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs-18_x
        wget
      ];
    };
    pve2 = {
      enable = true;
      url = "https://git.dechnik.net";
      tokenFile = config.sops.secrets.gitea-runner2.path;
      name = "pve";
      labels = [
        "ubuntu-latest:docker://ubuntu:latest"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs-18_x
        wget
      ];
    };
  };
  users.users.gitea-runner = {
    createHome = false;
    isSystemUser = true;
    group = "gitea-runner";
  };
  users.groups.gitea-runner = {};
}
