{ ... }:
let
  kubeIP = "100.64.0.6";
  kubeHostname = "kube-api.pve.dechnik.net";
  kubeApiPort = 6443;
in
{
  services.kubernetes = {
    roles = ["master" "node"];
    addons.dns.enable = true;
    kubelet.extraOpts = "--fail-swap-on=false";
    masterAddress = kubeHostname;
    apiserverAddress = "https://${kubeHostname}:${toString kubeApiPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeApiPort;
      advertiseAddress = kubeIP;
    };
  };
}
