{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-sec.fail2ban;
in
{
  config = lib.mkIf cfg {
    services.fail2ban = {
      enable = true;
      maxretry = 3;
      ignoreIP = [
        "192.168.0.0/24"
      ];
      bantime = "24h";
      bantime-increment = {
        enable = true;
        formula = "ban.Time * math.exp(float(ban.Count+1)*0.5)/math.exp(1*0.5)";
        maxtime = "168h";
        overalljails = true;
      };
      jails = {
        nginx-url-probe.settings = {
          enable = true;
          filter = "nginx-url-probe";
          logpath = "/var/log/nginx/access.log";
          action = ''
            %(action_)s[blocktype=DROP]
                                   ntfy'';
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "48h";
        };
        sshd.settings = {
          enable = true;
          filter = "sshd";
          action = "iptables-multiport[name=SSH, port=\"ssh\"]";
          logpath = "/var/log/auth.log";
          maxretry = 3;
        };
      };
    };
    environment.etc = {
      "fail2ban/action.d/ntfy.local".text = pkgs.lib.mkDefault (
        pkgs.lib.mkAfter ''
        [Definition]
        norestored = true # Needed to avoid receiving a new notification after every restart
        actionban = curl -H "Title: <ip> has been banned" -d "<name> jail has banned <ip> from accessing $(hostname) after <failures> attempts of hacking the system." https://ntfy.sh/Fail2banNotifications
        ''
      );
      "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault (
        pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000|=PHPE9568F36-D428-11d2-A769-00AA001ACF42|=PHPE9568F35-D428-11d2-A769-00AA001ACF42|=PHPE9568F34-D428-11d2-A769-00AA001ACF42)|\\x[0-9a-zA-Z]{2})
        ''
      );
    };
  };
}
