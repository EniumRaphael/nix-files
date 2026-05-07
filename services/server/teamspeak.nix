{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.server.teamspeak;
in
{
  config = lib.mkIf cfg {
    networking.firewall = {
      allowedTCPPorts = [
        9987
      ];
      allowedUDPPorts = [
        9987
      ];
    };
    services = {
      teamspeak3 = {
        enable = true;
      };
      nginx = {
        enable = true;
        virtualHosts."ts.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9987";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_ssl_verify off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
            '';
          };
        };
      };
    };
  };
}
