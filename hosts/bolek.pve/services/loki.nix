{ pkgs
, lib
, config
, ...
}:
let
  retention = "24h";

  domain = "loki.pve.dechnik.net";
in
{
  environment.persistence = {
    "/persist".directories = [
      "/var/lib/loki"
    ];
  };
  services.loki = {
    enable = true;

    configuration = {
      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9095;
      };

      auth_enabled = false;

      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "boltdb";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = retention;
            };
          }
        ];
      };

      # Distributor
      distributor.ring.kvstore.store = "inmemory";

      # Ingester
      ingester = {
        lifecycler.ring = {
          kvstore.store = "inmemory";
          replication_factor = 1;
        };
        lifecycler.interface_names = [ config.my.lan "wg0" "tailscale0" "ens20" ];
        chunk_encoding = "snappy";
        # Disable block transfers on shutdown
        max_transfer_retries = 0;
      };

      storage_config = {
        boltdb = {
          directory = "${config.services.loki.dataDir}/index";
        };

        filesystem = {
          directory = "${config.services.loki.dataDir}/storage";
        };
      };

      chunk_store_config = {
        max_look_back_period = retention;
      };

      table_manager = {
        retention_deletes_enabled = true;
        retention_period = retention;
      };

      limits_config = {
        split_queries_by_interval = "24h";
        ingestion_burst_size_mb = 16;
      };

      ruler = {
        # storage = {
        #   type = "local";
        #   local.directory = rulerDir;
        # };
        rule_path = "${config.services.loki.dataDir}/ruler";
        # alertmanager_url = "http://alertmanager.r";
        ring.kvstore.store = "inmemory";
      };

      # Query splitting and caching
      query_range = {
        cache_results = true;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    services.loki = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"; }];
    };

    routers.loki = {
      rule = "Host(`${domain}`)";
      service = "loki";
      entryPoints = [ "dechnik-ips" "web" ];
    };
  };
}
