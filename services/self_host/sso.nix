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
  vaultLogo = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/ba5519167634ebe1e1f0fc10d610d10d1f405101/resources/vaultwarden-icon.svg";
    name = "vault.svg";
    sha256 = "sha256-xY/pFVS9puG+Ub0M9WrISrY/eY1Rc+QeceGqHeUVx+8=";
  };
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "kanidm-admin" = {
        file = ../../secrets/kandim-admin.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };

      "kanidm-idmAdmin" = {
        file = ../../secrets/kandim-idmAdmin.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
    };

    users = {
      groups.kanidm = { };
      users.kanidm = {
        isSystemUser = true;
        group = "kanidm";
        extraGroups = [ "nginx" ];
      };
    };
    security.acme.certs."auth.enium.eu".group = "nginx";
    services = {
      kanidm = {
        package = pkgs.kanidmWithSecretProvisioning_1_9;
        server = {
          enable = true;
          settings = {
            domain = "enium.eu";
            origin = "https://auth.enium.eu";
            bindaddress = "127.0.0.1:9000";
            tls_chain = "/var/lib/acme/auth.enium.eu/fullchain.pem";
            tls_key = "/var/lib/acme/auth.enium.eu/key.pem";
          };
        };
        client = {
          enable = true;
          settings.uri = config.services.kanidm.server.settings.origin;
        };
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
              groups = [
                "grafana_superadmins"
                "forgejo_admins"
                "nextcloud_admins"
                "vault_admins"
              ];
            };
            deborah = {
              displayName = "Deborah";
              legalName = "Deborah Parodi";
              mailAddresses = [
                "deborah@enium.eu"
              ];
              groups = [
                "grafana_superadmins"
                "forgejo_users"
                "vault_users"
              ];
            };
          };
          groups = {
            grafana_superadmins = {
              present = true;
            };
            grafana_admins = {
              present = true;
            };
            grafana_editors = {
              present = true;
            };
            grafana_users = {
              present = true;
            };
            forgejo_admins = {
              present = true;
            };
            forgejo_users = {
              present = true;
            };
            vault_admins = {
              present = true;
            };
            vault_users = {
              present = true;
            };
            nextcloud_admins = {
              present = true;
            };
            nextcloud_user = {
              present = true;
            };
          };
        };
      };
      nginx = {
        enable = true;
        virtualHosts."auth.enium.eu" = {
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
  };
}
