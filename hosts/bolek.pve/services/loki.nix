{
  pkgs,
  lib,
  config,
  ...
}:
let
  retention = "24h";

  domain = "loki.pve.dechnik.net";
in
{
  environment.persistence = {
    "/persist".directories = [ "/var/lib/loki" ];
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
            from = "2024-05-29";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
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
        lifecycler.interface_names = [
          config.my.lan
          "wg0"
          "tailscale0"
          "ens20"
        ];
        chunk_encoding = "snappy";
        # Disable block transfers on shutdown
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "${config.services.loki.dataDir}/tsdb-index";
          cache_location = "${config.services.loki.dataDir}/tsdb-cache";
          cache_ttl = "24h";
        };

        filesystem = {
          directory = "${config.services.loki.dataDir}/storage";
        };
      };

      # chunk_store_config = {
      #   max_look_back_period = retention;
      # };

      table_manager = {
        retention_deletes_enabled = true;
        retention_period = retention;
      };

      limits_config = {
        split_queries_by_interval = "24h";
        ingestion_burst_size_mb = 16;
        retention_period = retention;
      };
      compactor = {
        working_directory = "${config.services.loki.dataDir}/retention";
        retention_enabled = true;
        retention_delete_delay = "2h";
        retention_delete_worker_count = 150;
        delete_request_store = "filesystem";
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
      loadBalancer.servers = [
        { url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"; }
      ];
    };

    routers.loki = {
      rule = "Host(`${domain}`)";
      service = "loki";
      entryPoints = [ "web" ];
      middlewares = [ "dechnik-ips" ];
    };
  };
}
