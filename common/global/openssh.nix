{ outputs, lib, config, ... }:

let
  hosts = outputs.nixosConfigurations;
  hostname = config.networking.hostName;
  pubKey = host: ../../hosts/${host}/ssh_host_ed25519_key.pub;
  # Sops needs acess to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  hasOptinPersistence = config.environment.persistence ? "/persist";
in
{
  services.openssh = {
    enable = true;
    # Harden
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
      GatewayPorts = "clientspecified";
    };
    # Allow forwarding ports to everywhere

    hostKeys = [{
      path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  sops.secrets.ssh-config = {
    sopsFile = ../secrets.yaml;
    group = "users";
    mode = "0440";
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts = builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames = lib.optional (name == hostname) "localhost";
      })
      hosts;
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.sshAgentAuth.enable = true;
}
