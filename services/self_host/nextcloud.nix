{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.nextcloud;
  dataDir = "/mnt/data/nextcloud";
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      php
    ];
    users = {
      groups.datausers = { };
      users = {
        nextcloud.extraGroups = [ "datausers" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/data 2770 root datausers -"
    ];
    services = {
      nextcloud = {
        enable = true;
        https = true;
        package = pkgs.nextcloud32;
        hostName = "nextcloud.enium.eu";
        datadir = dataDir;
        config = {
          adminpassFile = "/etc/nextcloud-pass.txt";
          adminuser = "OwnedByTheEniumTeam";
          dbtype = "sqlite";
        };
        settings = {
          trusted_domains = [
            "192.168.1.254"
          ];
          default_phone_region = "FR";
        };
      };
      nginx.virtualHosts."nextcloud.enium.eu".enableACME = true;
      nginx.virtualHosts."nextcloud.enium.eu".forceSSL = true;
      nginx.virtualHosts."nextcloud.enium.eu".locations."~ \.php$".extraConfig = ''
        fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
      '';
    };
  };
}
