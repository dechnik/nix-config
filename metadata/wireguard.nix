{
  servers = {
    pve = {
      additional_networks = ["10.60.0.0/16" "2a03:94e0:200d::/48"];
      addresses = ["10.69.0.200/32" "2a03:94e0:200d:69::200/128"];
      dns = "10.60.0.1";
      endpoint_address = "pve.dechnik.net";
      endpoint_port = 51820;
      public_key = "yeaH7Y6HILS1Rc/KdaSLZltGng1hPGgpSgWZKBHrGRk=";
    };
  };

  clients = {
  };
}
