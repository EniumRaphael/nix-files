{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.sso;
  kanidm-admin = config.age.secrets."kanidm-admin".path;
  kanidm-idmAdmin = config.age.secrets."kanidm-idmAdmin".path;
in
  {
  config = lib.mkIf cfg {
    users = {
      groups.kanidm = {};
      users.kanidm = {
        isSystemUser = true;
        group = "kanidm";
        extraGroups = [ "nginx" ];
      };
    };
    security.acme.certs."auth.enium.eu".group = "nginx";
    services = {
      kanidm = {
        package = pkgs.kanidmWithSecretProvisioning_1_8;
        enableServer = true;
        serverSettings = {
          role = "WriteReplica";
          domain = "enium.eu";
          origin = "https://auth.enium.eu";
          bindaddress = "127.0.0.1:9000";
          tls_chain = "/var/lib/acme/auth.enium.eu/fullchain.pem";
          tls_key = "/var/lib/acme/auth.enium.eu/key.pem";
        };
        enableClient = true;
        clientSettings.uri = config.services.kanidm.serverSettings.origin;
        provision = {
          enable = true;
          autoRemove = false;
          adminPasswordFile = kanidm-admin;
          idmAdminPasswordFile = kanidm-idmAdmin;
          persons = {
            raphael = {
              displayName = "Raphael";
              legalName = "Raphael Parodi";
              mailAddresses = [
                "raphael@enium.eu"
              ];
            };
          };
        };
      };
      nginx.virtualHosts."auth.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://127.0.0.1:9000";
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
}
