{ config, ... }:

let
  vaultEnv = config.age.secrets.vault-secret-env.path;
in
{
  services.vaultwarden = {
    enable = true;

    environmentFile = vaultEnv;

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

  services.nginx.virtualHosts."vault.enium.eu" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8222";
      proxyWebsockets = true;
    };
  };
}
