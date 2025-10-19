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
      users.nextcloud.extraGroups = [
          "datausers"
        ];
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
      extraApps = {
        oidc_login.enable = true;
      };
      settings = {
        trusted_domains = [
          "192.168.1.254"
          "nextcloud.enium.eu"
        ];
        default_phone_region = "FR";
        "oidc_login_provider_url" = "https://auth.enium.eu/application/o/nextcloud/";
        "oidc_login_client_id" = "xxxxxxxxxxxx";
        "oidc_login_client_secret" = "yyyyyyyyyyyy";
        "oidc_login_end_session_redirect" = true;
        "oidc_login_auto_redirect" = true;
        "oidc_login_hide_password_form" = true;
        "oidc_login_use_id_token" = true;
        "oidc_login_scope" = "openid profile email";
        "oidc_login_disable_registration" = false;
        "oidc_login_button_text" = "Se connecter avec Enium";
        "oidc_login_default_group" = "";
        "oidc_login_unique_id_claim" = "sub";
        "oidc_login_mapping_displayname" = "name";
        "oidc_login_mapping_email" = "email";
      };
    };
    };
      nginx.virtualHosts."nextcloud.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."~ \.php$".extraConfig = ''
          fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
        '';
      };
    };
  };
}
