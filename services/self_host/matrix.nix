{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.matrix;
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    services = {
      matrix-tuwunel = {
        enable = true;
        settings.global = {
          server_name = "matrix.enium.eu";
          address = [
            "127.0.0.1"
          ];
          port = [
            6167
          ];
          allow_federation = true;
        };
      };
      nginx = {
        enable = true;
        virtualHosts."matrix.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:6167";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
