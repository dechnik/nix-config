{pkgs, config, ...}:
{
  environment.systemPackages = [
    pkgs.nodejs-18_x
  ];
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
    };
    pve2 = {
      enable = true;
      url = "https://git.dechnik.net";
      tokenFile = config.sops.secrets.gitea-runner2.path;
      name = "pve";
      labels = [
        "ubuntu-latest:docker://ubuntu:latest"
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
