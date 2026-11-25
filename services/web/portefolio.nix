{
  inputs,
  config,
  lib,
  ...
}:

let
  cfg = config.service.web.portefolio;
in
{
  imports = [
    inputs.portefolio.nixosModules.default
  ];

  config = lib.mkIf cfg {
    services.portefolio = {
      enable = true;
      domains = [
        "raphael.parodi.tech"
        "raphael.parodi.pro"
      ];
      user = "nginx";
      group = "nginx";
      createUser = false;
    };

    services.nginx = {
      virtualHosts."parodi.tech" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "404";
        };
      };
      virtualHosts."parodi.pro" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          return = "404";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
