{
  servers = {
    pve = {
      additional_networks = [ "10.60.0.0/16" "2a03:94e0:200d::/48" ];
      addresses = [ "10.69.0.200/32" "2a03:94e0:200d:69::200/128" ];
      dns = "10.60.0.1";
      endpoint_address = "pve.dechnik.net";
      endpoint_port = 51820;
      public_key = "yeaH7Y6HILS1Rc/KdaSLZltGng1hPGgpSgWZKBHrGRk=";
    };
    oracle = {
      additional_networks = [ "10.61.0.0/24" ];
      addresses = [ "10.69.0.201/32" "2a03:94e0:200d:69::201/128" ];
      dns = "10.61.0.1";
      endpoint_address = "oracle.dechnik.net";
      endpoint_port = 51820;
      public_key = "bX6+fkSSQwEkvlTG1FopF0whOSk28O1zoTyI8+wSBng=";
    };
    hetzner = {
      additional_networks = [ "10.62.0.0/16" ];
      addresses = [ "10.69.0.202/32" "2a03:94e0:200d:69::202/128" ];
      endpoint_address = "hetzner.dechnik.net";
      endpoint_port = 51820;
      public_key = "uGZRtR1CK9p66IrWbvpetPRRYk6f2C1w1R2UuHjfLC4=";
    };
  };

  clients = {
    dziad = {
      additional_networks = [ ];
      addresses = [ "10.69.0.1/32" "2a03:94e0:200d:69::1/128" ];
      public_key = "lsOMuYxWnrz5m8sxobCqqLhSMIRbR0AWnqvq6kwXims=";
    };
    ldlat = {
      additional_networks = [ ];
      addresses = [ "10.69.0.2/32" "2a03:94e0:200d:69::2/128" ];
      public_key = "Km8A6+E1PyFXN/RFLTJEmA7Q4fy9SIbFq99GyUgWmQw=";
    };
    moto = {
      additional_networks = [ ];
      addresses = [ "10.69.0.10/32" ];
      public_key = "nZ74UF6t++0EugNPZIuu+uc89CVR/DNw2iaY4M4VsRg=";
    };
  };
}
