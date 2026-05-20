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
        package = pkgs.kanidmWithSecretProvisioning_1_10;
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
            nathe = {
              displayName = "Nathe";
              legalName = "Nathe Siefert";
              mailAddresses = [
                "nathesiefert@enium.eu"
              ];
              groups = [
                "nextcloud_user"
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
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
