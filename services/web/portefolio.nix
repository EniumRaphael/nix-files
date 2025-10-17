{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.web.portefolio;
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      nodejs
      pnpm
    ];
    users = {
      groups.web_portefolio = {
        name = "web_portefolio";
      };
      users.web_portefolio = {
        description = "Utilisateur pour le bot BDE";
        group = "web_portefolio";
        home = "/opt/portefolio/";
        isSystemUser = true;
      };
    };

    services.nginx = {
      virtualHosts."raphael.parodi.pro" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/opt/portefolio/dist";
          index = "index.html";
          extraConfig = ''
            try_files $uri /index.html;
          '';
        };
      };
    };
    security.acme = {
      certs = {
        "raphael.parodi.pro" = { };
      };
    };
  };
}
