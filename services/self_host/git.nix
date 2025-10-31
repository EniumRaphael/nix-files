{ config, pkgs, lib, ... }:

let
  giteaDomain = "git.enium.eu";
in
{
  services.gitea = {
    enable = true;
    appName = "Enium Git";
    user = "gitea";
    group = "gitea";
    database.type = "sqlite3";

    settings = {
      server = {
        DOMAIN = giteaDomain;
        ROOT_URL = "https://${giteaDomain}/";
        SSH_PORT = 42131;
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3042;
        DISABLE_REGISTRATION = true;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        DISABLE_REGULAR_LOGIN = true;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
      };

      web = {
        DISABLE_LOCAL_LOGIN = true;
      };

      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
      };
    };
  };

  services.nginx.virtualHosts."${giteaDomain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3042";
    };
  };
}
