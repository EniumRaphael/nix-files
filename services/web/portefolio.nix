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
    services.nginx = {
      virtualHosts."parodi.pro" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "404";
        };
      };
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
        "parodi.pro" = {};
        "raphael.parodi.pro" = {};
      };
    };
  };
}
