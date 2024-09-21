{
  pkgs,
  config,
  lib,
  ...
}:
let
  ollama-port = toString config.services.ollama.port;
  searx-port = toString config.services.searx.settings.server.port;
in
{
  sops.secrets.searx-env = {
    owner = "searx";
    group = "searx";
    sopsFile = ../secrets.yaml;
  };
  services.ollama = {
    package = pkgs.ollama-cuda;
    enable = true;
    host = "10.60.0.2";
    port = 11434;
    acceleration = "cuda";
    user = "ollama";
    group = "ollama";
  };
  users.users.ollama.extraGroups = [ "video" "render" ];
  services.open-webui = {
    enable = true;
    host = "10.60.0.2";
    port = 8080;
    openFirewall = false;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://10.60.0.2:${ollama-port}";
      # Disable authentication
      WEBUI_AUTH = "True";
      ENABLE_SIGNUP = "False";
      WEBUI_URL = "http://localhost:8080";
      # Search
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://10.60.0.2:${searx-port}/search?q=<query>";
      # fix crush on web search
      # RAG_EMBEDDING_ENGINE = "ollama";
      # RAG_EMBEDDING_MODEL = "mxbai-embed-large:latest";
      PYDANTIC_SKIP_VALIDATING_CORE_SCHEMAS = "True";
    };
  };
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    runInUwsgi = false;
    settings = {
      general.enable_metrics = false;
      search = {
        safe_search = 0;
        formats = [ "html" "csv" "json" "rss" ];
      };
      server = {
        port = 8081;
        bind_address = "10.60.0.2";
        public_instance = false;
        limiter = false;
        http_protocol_version = "1.1";
        secret_key = "@SEARX_SECRET_KEY@";
      };
      ui = {
        default_locale = "en";
        theme_args.simple_style = "dark";
      };
    };
    environmentFile = config.sops.secrets.searx-env.path;
  };

  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
  };
  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ollama";
    Group = "ollama";
  };
}
