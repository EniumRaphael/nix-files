{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.sso;
  kanidm-admin = config.age.secrets."kanidm-admin".path;
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
        package = pkgs.kanidm_1_8;
        provision = {
          idmAdminPasswordFile = kanidm-admin;
          persons = {
            raphael = {
              legalName = "Raphael Parodi";
              displayName = "Raphael";
              mailAddresses = [
                "raphael@enium.eu"
              ];
              groups = [
                "users"
                "idm_admins"
              ];
            };
          };
        };
        enableClient = true;
        clientSettings.uri = "https://auth.enium.eu";
        enableServer = true;
        serverSettings = {
          role = "WriteReplica";
          domain = "enium.eu";
          origin = "https://auth.enium.eu";
          bindaddress = "127.0.0.1:9000";
          tls_chain = "/var/lib/acme/auth.enium.eu/fullchain.pem";
          tls_key = "/var/lib/acme/auth.enium.eu/key.pem";
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
