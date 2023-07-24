{config, ...}:
{
  sops.secrets = {
    gitea-runner = {
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
  };
  users.users.gitea-runner = {
    createHome = false;
    isSystemUser = true;
    group = "gitea-runner";
  };
  users.groups.gitea-runner = {};
}
