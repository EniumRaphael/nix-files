{
config,
pkgs,
lib,
...
}:
let
  cfg = config.service.selfhost.jellyfin;
in
  {
  config = lib.mkIf cfg {
    users = {
      groups.datausers = { };
      users = {
        jellyfin.extraGroups = [ "datausers" ];
      };
    };
    services = {
      jellyfin = 
        {
          enable = true;
          dataDir = "/mnt/data/media";
          openFirewall = true;
        };

    qbittorrent = {
      enable = true;
      openFirewall = true;
      user = "qbittorrent";
      group = "datausers";

      webuiPort = 8137;

      serverConfig = {
        Preferences = {
          Downloads = {
            SavePath = "/mnt/data/downloads";
            TempPathEnabled = false;
          };
          General = {
            Locale = "fr_FR";
          };
          WebUI = {
            Username = "raphael";
            Password_PBKDF2 = "@ByteArray(CmH/e4LVehCMTT2BUTVo5g==:VqhgnDIsg0owhZqINmi6O0Ac3tXgz6JYAkxB7sqSH18VPQ6R6Tz9jT2a6KXtld4wG6ld41nFXSst0UqRFTUTUw==)";
          };
        };
      };
    };
      flaresolverr = {
        enable = true;
        openFirewall = true;
        port = 8191;
      };
      radarr = {
        enable = true;
        dataDir = "/var/lib/radarr";
        user = "radarr";
        group = "datausers";
        openFirewall = true;
      };

      prowlarr = {
        enable = true;
        dataDir = "/var/lib/prowlarr";
        openFirewall = true;
      };

      bazarr.enable = true;

      nginx.virtualHosts = {
        "jellyfin.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
          };
        };
        "radarr.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:7878";
          };
        };
      };
    };
  };
}
