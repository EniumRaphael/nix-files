{
  config,
  pkgs,
  lib,
  ...
}:

let
  gitDomain = "git.enium.eu";
in
{
  services = {
    forgejo = {
      enable = true;
      database.type = "postgres";

      settings = {
        server = {
          "DEFAULT.APP_NAME" = "Enium Git";
          "DEFAULT.APP_SLOGAN" = "Born2Code";
          DOMAIN = gitDomain;
          ROOT_URL = "https://${gitDomain}/";
          SSH_PORT = 42131;
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3042;
        };

        oauth2 = {
          ENABLED = true;
          NAME = "Enium";
          CLIENT_ID = "forgejo";
          CLIENT_SECRET = "${config.age.secrets.forgejo-oidc-secret.path}";
          SCOPES = "openid email profile groups";
          LOGIN_ATTRIBUTE_PATH = "preferred_username";
          AUTH_URL = "https://git.enium.eu/ui/oauth2";
          TOKEN_URL = "https://git.enium.eu/oauth2/token";
          API_URL = "https://git.enium.eu/oauth2/openid/forgejo/userinfo";
          REDIRECT_URI = "https://git.enium.eu/user/oauth2/Enium/callback";
          CODE_CHALLENGE_METHOD = "S256";
          ENABLE_AUTO_REGISTRATION = true;
          UPDATE_AVATAR = true;
        };

        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          DISABLE_PASSWORD_SIGNIN_FORM = true;
        };
        security = {
          LOGIN_REMEMBER_DAYS = 14;
        };
      };
    };
    gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        name = "monolith";
        url = "https://git.enium.eu";
        tokenFile = config.age.secrets.forgejo-runner-token.path;
        labels = [
          "ubuntu-latest:docker://node:16-bullseye"
        ];
      };
    };
    nginx.virtualHosts."${gitDomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3042";
        proxyWebsockets = true;
      };
    };
  };
}
