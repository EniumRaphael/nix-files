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
        ipv6 = true;
        fixed-cidr-v6 = "fd00:d0c:1::/64";
        ip6tables = true;
        default-address-pools = [
          {
            base = "172.17.0.0/12";
            size = 24;
          }
          {
            base = "fd00:d0c:2::/48";
            size = 64;
          }
        ];
        dns = [
          "10.64.0.1"
          "194.242.2.2"
          "2a07:e340::2"
          "194.242.2.3"
          "2a07:e340::3"
          "194.242.2.4"
          "2a07:e340::4"
          "194.242.2.5"
          "2a07:e340::5"
          "194.242.2.6"
          "2a07:e340::6"
          "194.242.2.9"
          "2a07:e340::9"
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
