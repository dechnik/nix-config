{ pkgs, config, lib, outputs, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;
  users.users.lukasz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ] ++ ifTheyExist [
      "network"
      "wireshark"
      "i2c"
      "mysql"
      "docker"
      "podman"
      "git"
      "libvirtd"
      "deluge"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDx9+QOcVSyjDsPGf0VZHlwVnzhY6k2eiaQX7OkqRjqWYh6Qu4yU8EVN7mDCvSl5ICNdQxUeD2Rkb7H3aToycIBcfALPv5FEBf4eG8j3KehVUINaYC1zy5eolPsc3/dg0MG2Vs/gfEmk+CBVTNeI3XTPPyo7cUX4p3mdK6jcF5XeXfidXbBAlvm7jpOqkAuRyn2zc+Dh2S2fyz9Hhd47+lnV8dKGg9L+BTXTjQS/GFdbjgSJtpBn5XPvF4Y6RaiofdmJnEnZo93OrK5sMyViITU0vSo5P3AdudPTmwf+IzmQcIhjQVIHAUuG9vCI5CRdyF1bY5sLWcmQuqJ0eUbt2fXfG+0PvBD2SEfhTOs/4gEhp/czqqYgScKp7v9tEqnkUEiPVZ9uOFVMRufozdQ0eAmLt/VLmqmd1iReoFuKTJT8iu6sv62bsaknPvAmIazMnIWoU1OYeSAGt8D6+AIMagdDrVENiIAYP043gk1XKcLBg5+uT95OoldGWzzdhctNe0= (none)"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCt+eIx7F5o2sY/YyBw8apNq9UeTXWKi2qF62qVsJuprrnxOapjJNCQS5ZpNNgsr9NzccLOYcM0to904rU6T0fKe4Rs52K65DK1RHq+1lv40GshKXxU8/V1SjtuJyJhDOXLZr7/C161RmX6Holddw5cFghmAnhuLOSrnR01EUM6uwg4lycWu4ipTawXtu42Y9lMLUSuFUR2rXt6Tidlzf4jGjz11J8PMvF2Uw+SiB7KoejGPVMrqZB8AuSWrtNTHNZ6cyYr03SaMFmCLM59EYkEIOSWd46/qeAgfaF9BmQoFzhYqDBr+YkjD1kCTZ+Z2wgwiEbjELkIFDL2scPqbQ+UyJIWCMcOocqGg71Z2uvQjt4IHwaH3J6cm5S4PjFjFfv3wztbA/kLm72nhV4afgRAizoERqhd5IwP0nX8gKAo8oqoAkcBmmE/dlEI7Jc99AzOVDdTYchfQ6PM2xDZkOE32u3ZIRKnKrHODLD3MfspCBpIOlv8imd+TNongSlbyFc= (none)"
    ];

    passwordFile = config.sops.secrets.lukasz-password.path;
  };

  sops.secrets.lukasz-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };


  services.geoclue2.enable = true;
  security.pam.services = { swaylock = { }; };
}
