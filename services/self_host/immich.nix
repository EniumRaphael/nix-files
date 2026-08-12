{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.immich;
in
{
  config = lib.mkIf cfg {
    age.secrets."immich-mail-password" = {
      file = ../../secrets/immich-mail-password.age;
      owner = "immich";
      group = "immich";
      mode = "0400";
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    users = {
      groups.datausers = { };
      users.immich.extraGroups = [
        "video"
        "render"
        "datausers"
      ];
    };
    services = {
      immich = {
        enable = true;
        port = 2283;
        openFirewall = true;
        mediaLocation = "/mnt/disks/immich";
        machine-learning.enable = true;
        redis.enable = true;
        server= {
          externalDomain = "immich.enium.eu";
          loginPageMessage = "Welcome to the cloud Enium";
          publicUsers = false;
        };
      notifications.smtp = {
          enabled = true;
          from = "immich@enium.eu";
          transport = {
            host = "smtp.migadu.com";
            ignoreCert = false;
            username = "immich@enium.eu";
            password._secret = config.age.secrets.immich-mail-password.path;
            port = 465;
            secure = true;
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts."immich.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = ''
              client_max_body_size 50000M;
              proxy_read_timeout   600s;
              proxy_send_timeout   600s;
              send_timeout         600s;
            '';
          };
        };
      };
    };
    systemd.tmpfiles.rules = [
        "d /mnt/disks 2770 immich datausers -"
      ];
  };
}
