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
          "llama3.1:8b"
          "qwen2.5:7b"
          "gemma2:9b"
          "codellama:7b"
          "phi3:14b"
          "phi3:mini"
          "qwen2.5:3b"
          "llama3.2:3b"
          "gemma2:2b"
          "qwen2.5-coder:7b"
          "codegemma:7b"
          "starcoder2:7b"
          "llama3.1:13b"
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
