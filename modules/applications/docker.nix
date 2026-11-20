{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.applications.docker;
in
{
  config = lib.mkIf cfg {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        dns = [
          "10.64.0.1"
          "194.242.2.3"
        ];
        log-driver = "local";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      docker
      docker-buildx
      docker-compose
    ];
  };
}
