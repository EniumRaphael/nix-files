{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.mail;
in
{
  config = lib.mkIf cfg {
    services.rspamd.enable = true;
    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.enium.eu";
      domains = [
        "enium.eu"
      ];
      loginAccounts = {
        "no-reply@enium.eu" = {
          hashedPasswordFile = "/root/mail-passwd.txt";
        };
      };
      certificateScheme = "acme-nginx";
    };

    services = {
      roundcube = {
        enable = true;
        hostName = "mail.enium.eu";
        extraConfig = ''
          					$config['smtp_host'] = "tls://mail.enium.eu";
          					$config['smtp_user'] = "%u";
          					$config['smtp_pass'] = "%p";
          				'';
      };
      nginx = {
        virtualHosts."mail.enium.eu" = {
          forceSSL = true;
          enableACME = true;
        };
      };
    };
  };
}
