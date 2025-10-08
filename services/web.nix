{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  portefolio = import ./web/portefolio.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  cfg = config.service.web;
in
{
  imports = [
    portefolio
  ];

  config = {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "raphael@parodi.pro";
      certs = {
        "raphael.parodi.pro" = { };
      };
    };
  };
  options.service.web = {
    portefolio = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the portefolio";
    };
  };
}
