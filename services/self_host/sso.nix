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
              groups = [
                "grafana_superadmins"
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
            grafana_user = {
              present = true;
            };
            nextcloud_user = {
              present = true;
            };
          };
          systems.oauth2 = {
            forgejo = {
              present = true;
              displayName = "Forjego";
              originUrl = "https://git.enium.eu";
              imageFile = kanidmLogo;
              originLanding = "https://git.enium.eu/user/oauth2/Enium/callback";
              basicSecretFile = config.age.secrets.forgejo-oidc-secret.path;
              public = false;
              enableLocalhostRedirects = false;
              allowInsecureClientDisablePkce = true;
              preferShortUsername = true;
              scopeMaps = {
                forgejo_admins = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
                forgejo_users = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
              };
              claimMaps = {
                groups = {
                  joinType = "array";
                  valuesByGroup = {
                    forgejo_admins = [
                      "forgejo_admins"
                    ];
                    forgejo_users = [
                      "forgejo_users"
                    ];
                  };
                };
              };
            };
            grafana = {
              present = true;
              displayName = "Grafana";
              originUrl = "https://monitor.enium.eu";
              originLanding = "https://monitor.enium.eu/login/generic_oauth";
              basicSecretFile = config.age.secrets.grafana-oidc-secret.path;
              public = false;
              enableLocalhostRedirects = false;
              allowInsecureClientDisablePkce = false;
              preferShortUsername = true;
              scopeMaps = {
                grafana_superadmins = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
                grafana_admins = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
                grafana_editors = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
                grafana_user = [
                  "email"
                  "openid"
                  "profile"
                  "groups"
                ];
              };
              claimMaps = {
                groups = {
                  joinType = "array";
                  valuesByGroup = {
                    grafana_superadmins = [
                      "grafana_superadmins"
                    ];
                    grafana_admins = [
                      "grafana_admins"
                    ];
                    grafana_editors = [
                      "grafana_editors"
                    ];
                    grafana_user = [
                      "grafana_user"
                    ];
                  };
                };
              };
            };
            nextcloud = {
              present = true;
              displayName = "Nextcloud";
              originUrl = "https://nextcloud.enium.eu";
              originLanding = "https://nextcloud.enium.eu/login";
              basicSecretFile = config.age.secrets.nextcloud-oidc-secret.path;
              public = false;
              enableLocalhostRedirects = false;
              allowInsecureClientDisablePkce = false;
              preferShortUsername = true;
              scopeMaps = {
                nextcloud_user = [
                  "openid"
                  "profile"
                  "email"
                ];
              };
              claimMaps = {
                email = {
                  joinType = "array";
                  valuesByGroup = {
                    nextcloud_user = ["mail"];
                  };
                };
                preferred_username = {
                  joinType = "array";
                  valuesByGroup = {
                    nextcloud_user = ["name"];
                  };
                };
                name = {
                  joinType = "array";
                  valuesByGroup = {
                    nextcloud_user = ["displayname"];
                  };
                };
              };
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
