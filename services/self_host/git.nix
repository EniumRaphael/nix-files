{ config, pkgs, lib, ... }:

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
          DISABLE_REGISTRATION = true;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          DISABLE_REGULAR_LOGIN = true;
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
          CODE_CHALLENGE_METHOD = "S256";
          ENABLE_AUTO_REGISTRATION = true;
          UPDATE_AVATAR = true;
        };

        security = {
          LOGIN_REMEMBER_DAYS = 14;
        };
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
