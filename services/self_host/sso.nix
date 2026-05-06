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
  forgejoLogo = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/doc-sheet/forgejo/refs/heads/forgejo/assets/logo.svg";
    name = "kanidm.svg";
    sha256 = "sha256-rP7aZURtHBfF2OYuGLcKZhbvIN+B596T/3kaOxHUvig=";
  };
  grafanaLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/a/a1/Grafana_logo.svg";
    name = "grafana.svg";
    sha256 = "sha256-UjE6ArLCa52o3XGUmpqPoakbEOeFi+zfsnATi1FtWmQ=";
  };
  nextcloudLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg";
    name = "nextcloud.svg";
    sha256 = "sha256-hL51zJkFxUys1CoM8yUxiH8BDw111wh3Qv7eTLm+XYo=";
  };
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
          systems.oauth2 = {
            forgejo = {
              present = true;
              displayName = "Forjego";
              imageFile = forgejoLogo;
              originUrl = "https://git.enium.eu";
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
              imageFile = grafanaLogo;
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
                grafana_users = [
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
                    grafana_users = [
                      "grafana_users"
                    ];
                  };
                };
              };
            };
            nextcloud = {
              present = true;
              displayName = "Nextcloud";
              imageFile = nextcloudLogo;
              originUrl = "https://nextcloud.enium.eu/apps/user_oidc/code";
              originLanding = "https://nextcloud.enium.eu/login";
              basicSecretFile = config.age.secrets.nextcloud-oidc-secret.path;
              public = false;
              enableLocalhostRedirects = false;
              allowInsecureClientDisablePkce = false;
              preferShortUsername = false;
              claimMaps = {
                groups = {
                  joinType = "array";
                  valuesByGroup = {
                    nextcloud_admins = [ "admin" ];
                  };
                };
              };
              scopeMaps = {
                nextcloud_admins = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                ];
                nextcloud_user = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                ];
              };
            };
            vault = {
              present = true;
              displayName = "Vault";
              imageFile = vaultLogo;
              originUrl = "https://vault.enium.eu";
              originLanding = "https://vault.enium.eu/identity/connect/oidc-signin";
              basicSecretFile = config.age.secrets.vault-oidc-secret.path;
              public = false;
              enableLocalhostRedirects = false;
              allowInsecureClientDisablePkce = false;
              preferShortUsername = true;
              scopeMaps = {
                vault_admins = [
                  "openid"
                  "profile"
                  "email"
                ];
                vault_users = [
                  "openid"
                  "profile"
                  "email"
                ];
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
