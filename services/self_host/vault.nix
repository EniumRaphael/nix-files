{
  config,
  pkgs,
  lib,
  ...
}:

let
  vaultLogo = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/ba5519167634ebe1e1f0fc10d610d10d1f405101/resources/vaultwarden-icon.svg";
    name = "vault.svg";
    sha256 = "sha256-xY/pFVS9puG+Ub0M9WrISrY/eY1Rc+QeceGqHeUVx+8=";
  };
  cfg = config.service.selfhost.vault;
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "vault-oidc-secret" = {
        file = ../../secrets/vault-oidc-secret.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };

      "vault-secret-env" = {
        file = ../../secrets/vault-secret-env.age;
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
      };
    };
    services = {
      vaultwarden = {
        enable = true;
        environmentFile = config.age.secrets.vault-secret-env.path;
        config = {
          DOMAIN = "https://vault.enium.eu";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = false;
          SSO_ENABLED = true;
          SSO_CLIENT_ID = "vault";
          SSO_CLIENT_SECRET = "cat ${config.age.secrets.vault-oidc-secret.path}";
          SSO_AUTHORITY = "https://auth.enium.eu/oauth2/openid/vault";
          SSO_SIGNUPS_MATCH_EMAIL = true;
          SSO_PKCE = true;
          SSO_SCOPES = "openid profile email";
          SSO_ONLY = true;
        };
      };
      kanidm.provision.systems.oauth2.vault = {
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
      nginx = {
        enable = true;
        virtualHosts."vault.enium.eu" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8222";
            proxyWebsockets = true;
          };
        };
      };
    };
    security.apparmor.policies.vaultwarden = {
      state = "enforce";
      profile = ''
        #include <tunables/global>
        profile vaultwarden /run/current-system/sw/bin/vaultwarden {
          #include <abstractions/base>
          #include <abstractions/nameservice>
          #include <abstractions/ssl_certs>
          /run/current-system/sw/bin/vaultwarden  r,
          /var/lib/vaultwarden/**  rw,
          /etc/vaultwarden/**      r,
          /var/log/vaultwarden/**  rw,
          network inet  stream,
          network inet6 stream,
          deny /home/**            rw,
          deny /root/**            rw,
          deny /etc/shadow         r,
          deny /etc/passwd         rw,
        }
      '';
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
