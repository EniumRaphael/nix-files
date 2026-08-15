{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.ollama;
in
{
  config = lib.mkIf cfg {
    services = {
      ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        environmentVariables = {
          OLLAMA_MAX_LOADED_MODELS = "1";
          OLLAMA_NUM_PARALLEL = "1";
          OLLAMA_KEEP_ALIVE = "5m";
          OLLAMA_FLASH_ATTENTION = "1";
        };
        loadModels = [
          "mistral:7b"
          "qwen3.5:9b"
          "ministral-3:8b "
          "gemma4:e4b"
        ];
      };

      open-webui = {
        enable = true;
        port = 13007;
      };
      nginx.virtualHosts."ollama.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:13007";
          proxyWebsockets = true;
        };
      };
    };
    nixpkgs.config.cudaSupport = true;
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
